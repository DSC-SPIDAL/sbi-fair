This is the compilation of the timings for the `short_train` test run on different hardware using the provided apptainer containers. The provided timings are mean and standard deviation from 5 runs (in seconds) or single run.

These tests use containers' default parameters (with overrides documented in test configuration files),
and might not be optimal for the testing hardware.

1. Testing hardware

   - P5570:

     - Intel(R) Core(TM) i9-12900H; cores 6P+8E; memory 32GB
     - NVIDIA RTX A2000; memory 8GB

   - Rivanna/V100:
     - 2x Intel(R) Xeon(R) Gold 6148; cores 40; memory 375GB
     - NVIDIA Tesla V100-SXM2; memory 32GB

2. Results

   | Model           |  P5570/CPU  |  P5570/A2000  | Rivanna/CPU  | Rivanna/V100 |
   | --------------- | :---------: | :-----------: | :----------: | :----------: |
   | autophasenn     |      ✗      |       ✗       | 1044.6 (5.6) |  59.0 (1.9)  |
   | calogan         |     ⏳      |      ⏳       |     1659     | 438.7 (2.7)  |
   | cosmoflow       |   1380.0    |     602.0     |     497      | 250.3 (2.5)  |
   | caloflow        |     ⏳      |      ⏳       |      ⏳      |     3125     |
   | nanoconfinement | 5.94 (0.16) |  9.9 (0.23)   |  8.92 (0.3)  | 16.67 (0.28) |
   | ptychonn        |      ✗      | 126.45 (0.33) |      ✗       | 78.10 (0.47) |

   ✗ - failed

   ⏳ - didn't finish (run time >2h for P5570, >4h for Rivanna)
