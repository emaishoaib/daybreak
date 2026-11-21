import CoreGraphics
import MetalKit
import Observation
import WorldTimeKit

struct GlobeUniforms {
    var sun: SIMD4<Float>
    var orientation: SIMD4<Float>
    var size: SIMD4<Float>
}

@MainActor
@Observable
final class GlobeRenderer {
    static let shared = GlobeRenderer()
    static let radiusFraction = 0.9

    private struct Request: Equatable {
        let width: Int
        let height: Int
        let orientation: GlobeOrientation
        let zoom: Double
        let sun: Coordinate
    }

    private var resources: GlobeResources?
    @ObservationIgnored private var loading: Task<Void, Never>?
    @ObservationIgnored private var target: MTLTexture?
    @ObservationIgnored private var last: (request: Request, image: CGImage)?

    static func radius(for size: CGSize, zoom: Double) -> Double {
        min(size.width, size.height) / 2 * radiusFraction * zoom
    }

    func prepare() {
        guard resources == nil, loading == nil else { return }
        loading = Task {
            resources = await Self.loadResources()
        }
    }

    func image(width: Int, height: Int, orientation: GlobeOrientation, zoom: Double, sun: Coordinate) -> CGImage? {
        let request = Request(width: width, height: height, orientation: orientation, zoom: zoom, sun: sun)
        if let last, last.request == request { return last.image }
        guard let resources else { prepare(); return nil }
        guard width > 0, height > 0, let image = render(request, with: resources) else { return nil }
        last = (request, image)
        return image
    }

    @concurrent
    private nonisolated static func loadResources() async -> sending GlobeResources? {
        MTLCreateSystemDefaultDevice().flatMap { try? GlobeResources(device: $0) }
    }

    private func render(_ request: Request, with resources: GlobeResources) -> CGImage? {
        guard let target = target(width: request.width, height: request.height, device: resources.queue.device),
              let commands = resources.queue.makeCommandBuffer() else { return nil }
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        pass.colorAttachments[0].storeAction = .store
        guard let encoder = commands.makeRenderCommandEncoder(descriptor: pass) else { return nil }

        var uniforms = Self.uniforms(for: request)
        encoder.setRenderPipelineState(resources.pipeline)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentTexture(resources.day, index: 0)
        encoder.setFragmentTexture(resources.night, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commands.commit()
        commands.waitUntilCompleted()
        return Self.image(from: target)
    }

    private func target(width: Int, height: Int, device: MTLDevice) -> MTLTexture? {
        if let target, target.width == width, target.height == height { return target }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        descriptor.usage = .renderTarget
        descriptor.storageMode = .shared
        target = device.makeTexture(descriptor: descriptor)
        return target
    }

    private static func uniforms(for request: Request) -> GlobeUniforms {
        let sunPoint = request.orientation.viewPoint(of: request.sun)
        let radius = radius(for: CGSize(width: request.width, height: request.height), zoom: request.zoom)
        return GlobeUniforms(
            sun: SIMD4(Float(sunPoint.x), Float(sunPoint.y), Float(sunPoint.z), 0),
            orientation: SIMD4(Float(request.orientation.centreLongitude * .pi / 180), Float(request.orientation.tilt * .pi / 180), 0, 0),
            size: SIMD4(Float(request.width), Float(request.height), Float(radius), 0)
        )
    }

    private static func image(from texture: MTLTexture) -> CGImage? {
        let bytesPerRow = texture.width * 4
        var bytes = Data(count: bytesPerRow * texture.height)
        bytes.withUnsafeMutableBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            texture.getBytes(base, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, texture.width, texture.height), mipmapLevel: 0)
        }
        guard let provider = CGDataProvider(data: bytes as CFData) else { return nil }
        return CGImage(
            width: texture.width,
            height: texture.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
}

private struct GlobeResources {
    let queue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    let day: MTLTexture
    let night: MTLTexture

    init(device: MTLDevice) throws {
        guard let queue = device.makeCommandQueue(), let library = device.makeDefaultLibrary() else { throw GlobeError.metalUnavailable }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "globeVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "globeFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let loader = MTKTextureLoader(device: device)
        self.queue = queue
        pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        day = try Self.texture(named: "EarthDay", loader: loader)
        night = try Self.texture(named: "EarthNight", loader: loader)
    }

    private static func texture(named name: String, loader: MTKTextureLoader) throws -> MTLTexture {
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") else { throw GlobeError.missingImage(name) }
        return try loader.newTexture(URL: url, options: [
            .generateMipmaps: true,
            .SRGB: false,
            .textureStorageMode: MTLStorageMode.private.rawValue,
        ])
    }
}

private enum GlobeError: Error {
    case metalUnavailable
    case missingImage(String)
}
