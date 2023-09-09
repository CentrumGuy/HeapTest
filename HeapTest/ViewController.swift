//
//  ViewController.swift
//  HeapTest
//
//  Created by Shahar Ben-Dor on 9/8/23.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private let mtlDevice = MTLCreateSystemDefaultDevice()!
    private lazy var commandQueue = mtlDevice.makeCommandQueue()!
    private lazy var heap = {
        let heapDescriptor = MTLHeapDescriptor()
        heapDescriptor.size = 9437184 // - 1048576
        heapDescriptor.hazardTrackingMode = .untracked
        heapDescriptor.storageMode = .private
        
        let heap = self.mtlDevice.makeHeap(descriptor: heapDescriptor)
        return heap!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mtkView = MTKView()
        view.addSubview(mtkView)
        
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mtkView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mtkView.widthAnchor.constraint(equalToConstant: 1362).isActive = true
        mtkView.heightAnchor.constraint(equalToConstant: 766).isActive = true
        
        mtkView.device = mtlDevice
        mtkView.delegate = self
    }


}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let renderDescriptor3 = view.currentRenderPassDescriptor else { return }
        
        print("== BEGIN RENDER ==")
        print("Heap empty? \(heap.usedSize == 0)")
        
        // Prepare renderpass 1
        let texture1Descriptor = MTLTextureDescriptor()
        texture1Descriptor.pixelFormat = .bgra8Unorm
        texture1Descriptor.width = 767
        texture1Descriptor.height = 767
        texture1Descriptor.textureType = .type2D
        texture1Descriptor.storageMode = self.heap.storageMode
        texture1Descriptor.usage = [.shaderRead, .renderTarget]
        
        let texture1 = self.heap.makeTexture(descriptor: texture1Descriptor)!
        texture1.label = "texture 1"
        
        let renderDescriptor1 = MTLRenderPassDescriptor()
        renderDescriptor1.colorAttachments[0].loadAction = .clear
        renderDescriptor1.colorAttachments[0].texture = texture1
        renderDescriptor1.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 1)
        renderDescriptor1.renderTargetWidth = texture1.width
        renderDescriptor1.renderTargetHeight = texture1.height
        
        // Render renderpass 1
        let command1 = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor1)!
        let fence1 = self.mtlDevice.makeFence()!
        command1.updateFence(fence1, after: .fragment)
        command1.endEncoding()
        
        
        
        
        
        // Prepare renderpass 2
        let stencilDescriptor = MTLTextureDescriptor()
        stencilDescriptor.pixelFormat = .stencil8
        stencilDescriptor.width = 936
        stencilDescriptor.height = 920
        stencilDescriptor.textureType = .type2D
        stencilDescriptor.storageMode = self.heap.storageMode
        stencilDescriptor.usage = .renderTarget
        
        let texture2Descriptor = MTLTextureDescriptor()
        texture2Descriptor.pixelFormat = .bgra8Unorm
        texture2Descriptor.width = stencilDescriptor.width
        texture2Descriptor.height = stencilDescriptor.height
        texture2Descriptor.textureType = .type2D
        texture2Descriptor.storageMode = self.heap.storageMode
        texture2Descriptor.usage = .renderTarget
        
        let stencil = self.heap.makeTexture(descriptor: stencilDescriptor)!
        let texture2 = self.heap.makeTexture(descriptor: texture2Descriptor)!
        stencil.label = "stencil texture"
        texture2.label = "texture 2"
        
        let renderDescriptor2 = MTLRenderPassDescriptor()
        renderDescriptor2.stencilAttachment.texture = stencil
        renderDescriptor2.stencilAttachment.clearStencil = 28
        renderDescriptor2.stencilAttachment.loadAction = .clear
        renderDescriptor2.colorAttachments[0].loadAction = .clear
        renderDescriptor2.colorAttachments[0].texture = texture2
        renderDescriptor2.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 1, alpha: 1)
        renderDescriptor2.renderTargetWidth = texture2.width
        renderDescriptor2.renderTargetHeight = texture2.height
        
        // Render renderpass 2
        let command2 = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor2)!
        let fence2 = self.mtlDevice.makeFence()!
        command2.waitForFence(fence1, before: .fragment)
        command2.useResource(texture1, usage: .read, stages: .fragment)
        command2.updateFence(fence2, after: .fragment)
        command2.endEncoding()
        
        
        
        
        
        
        // Prepare renderpass 3 (output texture, drawable)
        renderDescriptor3.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        // Render renderpass 3
        let command3 = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor3)!
        command3.waitForFence(fence2, before: .fragment)
        command3.endEncoding()
        
        
        
    
        
        // Print texture sizes
        print("Offscreen Texture", texture1.allocatedSize)
        print("Stencil Texture", stencil.allocatedSize)
        print("Main Texture", texture2.allocatedSize)
        
        // Make texture aliasable to free memory in the heap
        texture1.makeAliasable()
        texture2.makeAliasable()
        stencil.makeAliasable()
        
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
    
    
}

