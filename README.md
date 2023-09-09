# HeapTest
This repository demonstrates a bug I'm experiencing with MTLHeap.

To see the bug:
1. Run the app on MacCatalyst (I'm using Ventura 13.5.2) but it works on earlier versions of macOS as well.
2. Capture a frame in Metal
3. Observe the state of texture 1 right after Render 0. The texture should be green because it was cleared to the color green during Render 0
4. Observe the state of texture 1 right after the beginning of Render 1 by expanding line 20 of the render cycle: "[renderCommandEncoderWithDescriptor:<data>]" and clicking on the All Resources button. You will see that texture 1 is no longer green and that its data was changed during the clearing of Render 1 even though it wasn't attached as a rendertarget
