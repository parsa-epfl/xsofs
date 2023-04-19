# XiangShan over FireSim

This repository contains supported files to bring up [XiangShan](https://github.com/OpenXiangShan/XiangShan) on AWS cloud FPGAs with the help of [FireSim](https://github.com/firesim/firesim).

## Getting Started

Please note that you should have Vivado v2020.2 and at least 32 GB of memory on your machine to successfully complete this flow.

### Generate the Design Checkpoint (DCP)

```sh
$ cd fpga/src/firesim
$ make ip
$ make rtl
$ make top
$ make dcp
$ make tar
```

The output tarball, containing both the encrypted DCP and the manifest, is `fpga/src/firesim/dcp/SH_CL.tar`.

### Generate the Amazon FPGA Image (AFI)

Please refer to this [README](https://github.com/aws/aws-fpga/blob/master/hdk/README.md#step3) of the AWS FPGA HDK.

### Generate the host executable

```sh
$ cd verif
$ make fsim
```

The output executable is `repo/firesim/sim/build/firesim`.

## Publications

This work is a side-effect of our ISCA'50 paper **Imprecise Store Exceptions**. Please consider cite this paper.

> Siddharth Gupta, Yuanlong Li, Qingxuan Kang, Abhishek Bhattacharjee, Babak Falsafi, Yunho Oh, and Mathias Payer. 2023. **Imprecise Store Exceptions**. In Proceedings of the 50th Annual International Symposium on Computer Architecture (ISCA ’23), June 17–21, 2023, Orlando, FL, USA. ACM, New York, NY, USA, 15 pages.

[DOI](https://doi.org/10.1145/3579371.3589087)
