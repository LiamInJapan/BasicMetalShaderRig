import Metal
import MetalKit

class FluidSimulation {
    // Data structures and algorithms for the fluid simulation go here
    // ...

    // Initialize the fluid simulation
    init() {
        // Set up the data structures and algorithms for the fluid simulation
        // ...
    }

    // Update the fluid simulation state
    func update(dt: Float) {
        // Update the fluid simulation state based on the time step dt
        // ...
    }

    // Retrieve the vertex data for the fluid simulation
    //func vertexData() -> [FluidVertex] {
        // Compute the vertex data for the fluid simulation
        // ...
    //    return vertexData
    //}

    // Retrieve the index data for the fluid simulation
    func indexData() -> [UInt16] {
        // Compute the index data for the fluid simulation
        // ...
        return indexData()
    }
}

class FluidSimulationViewController: UIViewController, MTKViewDelegate {

    var device: MTLDevice!
    
    var timer: CADisplayLink! = nil
    
    private var indicesBuffer: MTLBuffer!
    
    @IBOutlet weak var metalView: MTKView!
    
    let vertexData:[Float] = [1.0, 1.0, 0.0,
                              -1.0, 1.0, 0.0,
                              -1.0, -1.0, 0.0,
                              1.0, 1.0, 0.0,
                              1.0, -1.0, 0.0,
                              -1.0, -1.0, 0.0]
    
    var vertexBuffer: MTLBuffer! = nil
    var kernelBuffer: MTLBuffer! = nil
    
    func initializeDevice() {
        // Set up the Metal device
        device = MTLCreateSystemDefaultDevice()
        
        // If the Metal device is not available, display an error message and return
        guard device != nil else {
            let alertController = UIAlertController(title: "Error", message: "Metal is not available on this device.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    var renderPipelineState: MTLRenderPipelineState!
    
    var computeEncoder: MTLComputeCommandEncoder!
    
    // Data structures and algorithms for the fluid simulation
    // var fluid: FluidSimulation

    // Shaders and rendering pipeline state
    var vertexFunction: MTLFunction?
    var fragmentFunction: MTLFunction?
    var kernelFunction: MTLFunction?

    func createComputePipelineState() {
        let library = device.makeDefaultLibrary()
        kernelFunction = (library?.makeFunction(name: "mainImage"))!
        
        do {
            computePipelineState = try device.makeComputePipelineState(function: kernelFunction!)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func createRenderPipelineState() {
        let library = device.makeDefaultLibrary()
        vertexFunction = (library?.makeFunction(name: "simple_vertex_function"))!
        fragmentFunction = (library?.makeFunction(name: "simple_fragment_function"))!
        
        // Set up the pipeline descriptor with the simple shaders
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        //pipelineDescriptor.depthAttachmentPixelFormat = .depthStencilPixelFormat
        
        let dataSize = vertexData.count *
         MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData,
         length: dataSize,
         options: .storageModeShared)
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initializeDevice()
        createRenderPipelineState()
        //createComputePipelineState()
    }
    
    func render()
    {
        // We can use this too...
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = device
        metalView.delegate = self
        commandQueue = device.makeCommandQueue()
        // Create a command buffer and use it to create the compute encoder
        let commandBuffer = commandQueue.makeCommandBuffer()
        //computeEncoder = commandBuffer!.makeComputeCommandEncoder()
        
        
        timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
        timer.add(to: .current, forMode: .common)
        
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Update viewport and projection matrix here, if necessary
        // ...
    }
    
    struct VertexOut {
        var texCoords: float2
    }
    
    func draw(in view: MTKView) {
        
        /*let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: Int(metalView.drawableSize.width),
            height: Int(metalView.drawableSize.height),
            mipmapped: false
        )
        outTextureDescriptor.usage = [.shaderWrite, .shaderRead]
        let outTexture = device.makeTexture(descriptor: outTextureDescriptor)
        let width = outTexture!.width
        let height = outTexture!.height*/
        
        guard let drawable = view.currentDrawable else {
          return
        }
        
        //kernelBuffer = device.makeBuffer(length: MemoryLayout<VertexOut>.stride * width * height, options: [])
        
        //let threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        //let threadgroupsPerGrid = MTLSize(width: (width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width, height: (height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height, depth: 1)
        
        // Use compute encoder
        //computeEncoder.setComputePipelineState(computePipelineState)
        //computeEncoder.setTexture(outTexture, index: 0)
        //computeEncoder.setBuffer(kernelBuffer, offset: 0, index: 1)
        //computeEncoder.setTexture(iChannel0, index: 0)
        //computeEncoder.setTexture(iChannel1, index: 0)
        
        //computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        // End encoding
        //computeEncoder.endEncoding()
        
        // Create a render pass descriptor to describe the render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear // 4
        renderPassDescriptor.colorAttachments[0]
          .clearColor = MTLClearColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        // Create a command buffer to hold the rendering commands
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // Create a render command encoder to encode the rendering commands
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        // Set the render pipeline state and the viewport
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
  
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(view.bounds.width), height: Double(view.bounds.height), znear: 0.0, zfar: 1.0))
        
        
        // End the render command encoder
        renderEncoder.endEncoding()

        // Schedule the command buffer for execution
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
