# XiangShan over FireSim (xsofs)

This repository contains supported files to bring up [XiangShan](https://github.com/OpenXiangShan/XiangShan) on [AWS cloud FPGAs](https://aws.amazon.com/ec2/instance-types/f1) with the help of [FireSim](https://github.com/firesim/firesim).

**What is XiangShan?**

> XiangShan (香山) is an open-source high-performance RISC-V processor project.

**What are AWS cloud FPGAs?**

> Amazon EC2 F1 instances use FPGAs to enable delivery of custom hardware accelerations. F1 instances are easy to program and come with everything you need to develop, simulate, debug, and compile your hardware acceleration code, including an FPGA Developer AMI and supporting hardware level development on the cloud. Using F1 instances to deploy hardware accelerations can be useful in many applications to solve complex science, engineering, and business problems that require high bandwidth, enhanced networking, and very high compute capabilities. Examples of target applications that can benefit from F1 instance acceleration are genomics, search/analytics, image and video processing, network security, electronic design automation (EDA), image and file compression and big data analytics.
>
> F1 instances provide diverse development environments: from low-level hardware developers to software developers who are more comfortable with C/C++ and openCL environments (available on our GitHub). Once your FPGA design is complete, you can register it as an Amazon FPGA Image (AFI), and deploy it to your F1 instance in just a few clicks. You can reuse your AFIs as many times as you like, and across as many F1 instances as you like. There is no software charge for the development tools when using the FPGA developer AMI and you can program the FPGAs on your F1 instance as many times as you like with no additional fees.

**What is FireSim?**

> FireSim is an open-source FPGA-accelerated full-system hardware simulation platform that makes it easy to validate, profile, and debug RTL hardware implementations at 10s to 100s of MHz. FireSim simplifies co-simulating ASIC RTL with cycle-accurate hardware and software models for other system components (e.g. I/Os). FireSim can productively scale from individual SoC simulations hosted on on-prem FPGAs (e.g., a single Xilinx Alveo board attached to a desktop) to massive datacenter-scale simulations harnessing hundreds of cloud FPGAs (e.g., on Amazon EC2 F1).

## Getting Started

Please refer to the [FireSim document](https://docs.fires.im/en/stable) and the [AWS FPGA document](https://github.com/aws/aws-fpga/blob/master/hdk/README.md) to understand the basic flow of wrapping user-provided hardware design with FireSim and running user-provided Custom Logic (CL) on Amazon EC2 f1 instances. In our case, the CL is the XiangShan cores wrapped by FireSim.

This repo only covers the step of generating the CL. The user should correctly set up a working Amazon account to use AWS services, including submitting the generated DCP to Amazon to create the Amazon FPGA Image (AFI) and running the AFI on EC2 f1 instances.

The CL can be generated on a local machine or on an Amazon cloud machine. Please note that you should have **Vivado v2020.2** installed and at least **32 GB** of memory in the machine to successfully complete this flow.

**Caveats**: Due to the capacity of Xilinx UltraScale+ VU9P used in AWS EC2 f1 instances, our design only supports at most **two** **minimal** XiangShan cores.

### Generate the DCP

```sh
$ cd fpga/src/firesim
$ make -C ip
$ make rtl
$ make top
$ make dcp
$ make tar
```

The output tarball, containing both the encrypted DCP and the manifest file, is `fpga/src/firesim/dcp.AreaOptimized_high.yes.AltSpreadLogic_low.Default/SH_CL.tar`. The user should then submit this tarball to Amazon to create the AFI.

### Generate the host executable

```sh
$ cd verif
$ make fsim
```

The output executable is `repo/firesim/sim/build/firesim`, which should be copied to and run on the EC2 f1 instance to control the simulation. The user should also prepare workloads to run on the XiangShan cores. Alternatively, one can download working boot binaries and filesystem images from [this repo](https://github.com/parsa-epfl/imprecise_store_exceptions).

## Publications

We build this repo as the infrastructure of our ISCA'23 paper: [**Imprecise Store Exceptions**](https://doi.org/10.1145/3579371.3589087). Please consider citing this paper.

> Siddharth Gupta, Yuanlong Li, Qingxuan Kang, Abhishek Bhattacharjee, Babak Falsafi, Yunho Oh, and Mathias Payer. 2023. **Imprecise Store Exceptions**. In Proceedings of the 50th Annual International Symposium on Computer Architecture (ISCA ’23), June 17–21, 2023, Orlando, FL, USA. ACM, New York, NY, USA, 15 pages.