# HeapTest
This repository demonstrates a bug I'm experiencing with MTLHeap.

To see the bug:
1. Run the app on MacCatalyst (I'm using Ventura 13.5.2) but it works on earlier versions of macOS as well.
2. Capture a frame in Metal
3. Observe the state of texture 1 right after Render 0. The texture should be green because it was cleared to the color green during Render 0
4. Observe the state of texture 1 right after the beginning of Render 1 by expanding line 20 of the render cycle: "[renderCommandEncoderWithDescriptor:<data>]" and clicking on the All Resources button. You will see that texture 1 is no longer green and that its data was changed during the clearing of Render 1 even though it wasn't attached as a rendertarget


<img width="1415" alt="Screenshot 2023-09-09 at 6 13 04 PM" src="https://github.com/CentrumGuy/HeapTest/assets/6200459/2aa1ebd0-d03e-406e-975b-bdb3e109c7f5">
<img width="1431" alt="Screenshot 2023-09-09 at 6 13 14 PM" src="https://github.com/CentrumGuy/HeapTest/assets/6200459/b6ab3e57-7e6f-4878-9559-0eef949b42b0">
<img width="1389" alt="Screenshot 2023-09-09 at 6 17 40 PM" src="https://github.com/CentrumGuy/HeapTest/assets/6200459/fdfc125e-8daa-4a3c-ba75-651a1c634b47">
