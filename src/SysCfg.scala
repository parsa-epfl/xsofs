// See LICENSE.md for license details

package xsofs

import  chisel3._

import  firrtl.options._

import  xiangshan._
import  xiangshan.frontend._
import  xiangshan.frontend.icache._
import  xiangshan.backend.dispatch._
import  xiangshan.backend.exu._
import  xiangshan.cache._
import  xiangshan.cache.mmu._
import  huancun._
import  system._
import  device._

import  midas._
import  midas.core._
import  midas.platform._
import  midas.widgets._
import  junctions._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.tile._
import  freechips.rocketchip.devices.debug._
import  freechips.rocketchip.diplomacy._


class WithLiteHart(n: Int) extends Config((site, here, up) => {
  case XLen           => 64
  case PMParameKey    => PMParameters(
//  NumPMP                         =  16,                 // default
//  NumPMA                         =  16                  // default
  )
  case DebugModuleKey => Some(DebugModuleParams(
    baseAddress                    =  BigInt(0x38020000), // default
//  nDMIAddrSize                   =  7,                  // default
//  nProgramBufferWords            =  16,                 // default
    nAbstractDataWords             =  2,
    nScratch                       =  2,
    hasBusMaster                   =  true,
//  clockGate                      =  true,               // default
    maxSupportedSBAccess           =  site(XLen),
//  supportQuickAccess             =  false,              // default
//  supportHartArray               =  true,               // default
//  nHaltGroups                    =  1,                  // default
//  nExtTriggers                   =  0,                  // default
//  hasHartResets                  =  false,              // default
//  hasImplicitEbreak              =  false,              // default
//  hasAuthentication              =  false,              // default
//  crossingHasSafeReset           =  true                // default
  ))
  case EnableJtag     => true.B
  case MaxHartIdBits  => 2
  case XSTileKey      => Seq.tabulate(n) { i =>
    XSCoreParameters(
//    HasPrefetch                  =  false,              // unused
      HartId                       =  i,
//    XLEN                         =  site(XLen),         // default
//    HasMExtension                =  true,               // default
//    HasCExtension                =  true,               // default
//    HasDiv                       =  true,               // unused
//    HasICache                    =  true,               // unused
//    HasDCache                    =  true,               // unused
//    AddrBits                     =  64,                 // unused
//    VAddrBits                    =  39,                 // default
//    HasFPU                       =  true,               // default
//    HasCustomCSRCacheOp          =  true,               // default
      FetchWidth                   =  4,
//    AsidLength                   =  16,                 // default
//    EnableBPU                    =  false,              // unused
//    EnableBPD                    =  false,              // unused
//    EnableRAS                    =  false,              // unused
//    EnableLB                     =  false,              // unused
//    EnableLoop                   =  false,              // unused
      EnableSC                     =  false,
//    EnableTlbDebug               =  false,              // default
//    EnableJal                    =  true,               // unused
//    EnableUBTB                   =  true,               // unused
//    UbtbGHRLength                =  4,                  // default
      EnableGHistDiff              =  false,
      UbtbSize                     =  16,
      FtbSize                      =  16,
      RasSize                      =  16,
//    CacheLineSize                =  512,                // default
//    FtbWays                      =  4,                  // default
      TageTableInfos               =  Seq(
        (512,  8, 8),
        (512, 16, 8),
        (512, 32, 8),
        (512, 64, 8)
      ),
//    ITTageTableInfos             =  ...,                // default
//    SCNRows                      =  512,                // disabled (EnableSC)
//    SCNTables                    =  4,                  // disabled (EnableSC)
//    SCCtrBits                    =  6,                  // disabled (EnableSC)
//    SCHistLens                   =  ...,                // disabled (EnableSC)
//    numBr                        =  2,                  // default
      branchPredictor              =  ((resp: BranchPredictionResp, p: Parameters) => {
        val ubtb = Module(new MicroBTB()(p))
        val tage = Module(new Tage_SC ()(p))
        val ftb  = Module(new FTB     ()(p))
        val ras  = Module(new RAS     ()(p))

        ubtb.io := DontCare
        tage.io := DontCare
        ftb .io := DontCare
        ras .io := DontCare

        ubtb.io.in.bits.resp_in(0) := resp
        tage.io.in.bits.resp_in(0) := ubtb.io.out.resp
        ftb .io.in.bits.resp_in(0) := tage.io.out.resp
        ras .io.in.bits.resp_in(0) := ftb .io.out.resp

        (Seq(ubtb, tage, ftb, ras), ras.io.out.resp)
      }),
      IBufSize                     =  16,
      DecodeWidth                  =  2,
      RenameWidth                  =  2,
      CommitWidth                  =  2,
      FtqSize                      =  8,
//    EnableLoadFastWakeUp         =  true,               // unused
      IssQueSize                   =  8,
      NRPhyRegs                    =  64,
      LoadQueueSize                =  12,
      StoreQueueSize               =  8,
      RobSize                      =  32,
      dpParams                     =  DispatchParameters(
        IntDqSize                  =  8,
        FpDqSize                   =  8,
        LsDqSize                   =  8,
        IntDqDeqWidth              =  3,
        FpDqDeqWidth               =  3,
        LsDqDeqWidth               =  3
      ),
      exuParameters                =  ExuParameters(
        JmpCnt                     =  1,                  // default
        AluCnt                     =  2,
        MulCnt                     =  0,                  // unused
        MduCnt                     =  1,
        FmacCnt                    =  1,
        FmiscCnt                   =  1,
        FmiscDivSqrtCnt            =  0,                  // unused
        LduCnt                     =  1,
        StuCnt                     =  1
      ),
      LoadPipelineWidth            =  1,
      StorePipelineWidth           =  1,
      StoreBufferSize              =  4,
      StoreBufferThreshold         =  3,
      EnsbufferWidth               =  2,
//    EnableLoadToLoadForward      =  false,              // default
//    EnableFastForward            =  false,              // default
//    EnableLdVioCheckAfterReset   =  true,               // default
//    EnableSoftPrefetchAfterReset =  true,               // default
//    EnableCacheErrorAfterReset   =  true,               // default
//    RefillSize                   =  512,                // unused
//    MMUAsidLen                   =  16,                 // default
      itlbParameters               =  TLBParameters(
        name                       = "itlb",
        fetchi                     =  true,
//      fenceDelay                 =  2,                  // default
        useDmode                   =  false,
//      normalNSets                =  1,                  // default
//      normalNWays                =  8,                  // default
//      superNSets                 =  1,                  // default
//      superNWays                 =  2,                  // default
//      normalReplacer             =  Some("random"),     // default
//      superReplacer              =  Some("plru"),       // default
//      normalAssociative          = "fa",                // default
//      superAssociative           = "fa",                // default
//      normalAsVictim             =  false,              // default
//      outReplace                 =  false,              // default
//      partialStaticPMP           =  false,              // default
//      outsideRecvFlush           =  false,              // default
//      saveLevel                  =  false               // default
      ),
      ldtlbParameters              =  TLBParameters(
        name                       = "ldtlb",
//      fetchi                     =  false,              // default
//      useDmode                   =  true,               // default
//      normalNSets                =  1,                  // default
//      normalNWays                =  8,                  // default
//      superNSets                 =  1,                  // default
//      superNWays                 =  2,                  // default
//      normalReplacer             =  Some("random"),     // default
//      superReplacer              =  Some("plru"),       // default
//      normalAssociative          = "fa",                // default
//      superAssociative           = "fa",                // default
//      normalAsVictim             =  false,              // default
//      outReplace                 =  false,              // default
        partialStaticPMP           =  true,
        outsideRecvFlush           =  true,
//      saveLevel                  =  false               // default
      ),
      sttlbParameters              =  TLBParameters(
        name                       = "sttlb",
//      fetchi                     =  false,              // default
//      useDmode                   =  true,               // default
//      normalNSets                =  1,                  // default
//      normalNWays                =  8,                  // default
//      superNSets                 =  1,                  // default
//      superNWays                 =  2,                  // default
//      normalReplacer             =  Some("random"),     // default
//      superReplacer              =  Some("plru"),       // default
//      normalAssociative          = "fa",                // default
//      superAssociative           = "fa",                // default
//      normalAsVictim             =  false,              // default
//      outReplace                 =  false,              // default
        partialStaticPMP           =  true,
        outsideRecvFlush           =  true,
//      saveLevel                  =  false               // default
      ),
//    refillBothTlb                =  false,              // default
//    btlbParameters               =  ...,                // unused
      l2tlbParameters              =  L2TLBParameters(
//      name                       = "l2tlb",             // default
        l1Size                     =  2,
//      l1Associative              = "fa",                // unused
//      l1Replacer                 =  Some("plru"),       // default
        l2nSets                    =  2,
        l2nWays                    =  2,
//      l2Replacer                 =  Some("setplru"),    // default
        l3nSets                    =  2,
        l3nWays                    =  2,
//      l3Replacer                 =  Some("setplru"),    // default
        spSize                     =  2,
//      spReplacer                 =  Some("plru"),       // default
//      ifilterSize                =  4,                  // default
//      dfilterSize                =  8,                  // default
        missqueueExtendSize        =  1,
        llptwsize                  =  1,
//      blockBytes                 =  64,                 // default
        enablePrefetch             =  false,
        ecc                        =  None
      ),
      NumPerfCounters              =  3,
      icacheParameters             =  ICacheParameters(
        nSets                      =  64,
        nWays                      =  8,
//      rowBits                    =  64,                 // unused
//      nTLBEntries                =  32,                 // unused
//      tagECC                     =  None,               // default
//      dataECC                    =  None,               // default
//      replacer                   =  Some("random"),     // default
        nMissEntries               =  2,
        nReleaseEntries            =  1,
        nProbeEntries              =  1,
        nPrefetchEntries           =  1,
//      hasPrefetch                =  false,              // default
//      nMMIOs                     =  1,                  // default
//      blockBytes                 =  64                  // default
      ),
      dcacheParametersOpt          =  Some(DCacheParameters(
        nSets                      =  64,
        nWays                      =  8,
//      rowBits                    =  64,                 // unused
        tagECC                     =  Some("parity"),     // TODO
        dataECC                    =  Some("parity"),     // TODO
//      replacer                   =  Some("setplru"),    // default
        nMissEntries               =  4,
        nProbeEntries              =  2,
        nReleaseEntries            =  6,
//      nMMIOEntries               =  1,                  // unused
//      nMMIOs                     =  1,                  // unused
//      blockBytes                 =  64,                 // default
        alwaysReleaseData          =  false
      )),
      L2CacheParamsOpt             =  None,
//    L2NBanks                     =  1,                  // disabled (L2CacheParamsOpt)
//    usePtwRepeater               =  false,              // unused
//    softPTW                      =  false               // default
    )
  }
})

class WithLiteL3(n: Int, ways: Int = 16, banks: Int = 1) extends Config((site, here, up) => {
  case SoCParamsKey =>
    SoCParameters(
//    EnableILA                    =  false,              // default
      PAddrBits                    =  36,
      extIntrs                     =  4,
//    timebase                     =  10000000,           // default
      L3NBanks                     =  banks,
      L3CacheParamsOpt             =  Some(HCCacheParameters(
        name                       = "l3",
        level                      =  3,
        ways                       =  ways,
        sets                       =  n * 1024 / 64 / ways / banks,
//      blockBytes                 =  64,                 // default
//      pageBytes                  =  4096,               // default
//      replacement                = "plru",              // default
        mshrs                      =  8,
//      dirReadPorts               =  1,                  // default
//      dirReg                     =  true,               // default
//      enableDebug                =  false,              // default
//      enablePerf                 =  false,              // default
//      channelBytes               =  ...,                // default
//      prefetch                   =  None,               // default
        clientCaches               =  Seq(CacheParameters(
          name                     = "l1d",
          sets                     =  64,
          ways                     =  8,
//        blockBytes               =  64,                 // default
//        aliasBitsOpt             =  None,               // default
//        inner                    =  Nil                 // default
        ), CacheParameters(
          name                     = "l1i",
          sets                     =  64,
          ways                     =  8,
//        blockBytes               =  64,                 // default
//        aliasBitsOpt             =  None,               // default
//        inner                    =  Nil                 // default
        )),
//      inclusive                  =  true,               // default
//      alwaysReleaseData          =  false,              // default
//      tagECC                     =  None,               // default
//      dataECC                    =  None,               // default
//      echoField                  =  Nil,                // default
//      reqField                   =  Nil,                // default
//      respKey                    =  Nil,                // default
//      reqKey                     =  ...,                // default
//      respField                  =  Nil,                // default
//      ctrl                       =  None,               // default
//      sramClkDivBy2              =  false,              // default
//      sramDepthDiv               =  1,                  // default
//      simulation                 =  false,              // default
//      innerBuf                   =  ...,                // default
//      outerBuf                   =  ...                 // default
      ))
    )
})

class WithDebug(f: Int, c: Int) extends Config((site, here, up) => {
  case MonitorsEnabled =>  c != 0

  case DebugOptionsKey =>
    val y = f != 0
    val n = f == 0
    val d = c != 0

    DebugOptions(
      FPGAPlatform                 =  y,
      EnableDifftest               =  d,
      AlwaysBasicDiff              =  d,
      EnableDebug                  =  n,
      EnablePerfDebug              =  n,
      EnableTLLogger               =  d,
//    UseDRAMSim                   =  false               // default
    )
})

class WithFireSim extends Config((site, here, up) => {
  case SynthAsserts       =>  false
  case SynthPrints        =>  false
  case AXIDebugPrint      =>  false

  case Platform           => (p: Parameters) => new F1Shim()(p)
  case HasDMAChannel      =>  true
  case HostMemNumChannels =>  4
  case HostMemChannelKey  =>
    HostMemChannelParams(
      size                         =  0x400000000L,
      beatBytes                    =  64,
      idBits                       =  16,
//    maxXferBytes                 =  256,                // default
    )
  case MemNastiKey =>
    NastiParameters(
      dataBits                     =  512,
      addrBits                     =  64,
      idBits                       =  4
    )
  case DMANastiKey =>
    NastiParameters(
      dataBits                     =  512,
      addrBits                     =  64,
      idBits                       =  4
    )
  case CtrlNastiKey =>
    NastiParameters(
      dataBits                     =  32,
      addrBits                     =  32,
      idBits                       =  0
    )

  case HostTransforms =>
    Seq(Dependency[RenameExtModule])
})


class SysCfg extends Config(
  new WithDebug   (Env.fpga, Env.chk) orElse
  new WithFireSim                     orElse
  new WithLiteHart(Env.hart)          orElse
  new WithLiteL3  (2048, 16)
)
