
#include "share/atspre_staload.hats"

#define ATS_DYNLOADFLAG 0

#define LIBS_targetloc "../libs" (* search path for external libs *)
#include "{$LIBS}/ats-bytestring/HATS/bytestring.hats"


fn
  test1
  ( i: !$BS.BytestringNSH1
  ): Option_vt( int) =
let
  fun
    __freelin
    {len,offset,cap,ucap,refcnt,n: nat | refcnt >= n}{dynamic:bool}{p:agz}
    .<n>.
    ( xs: list_vt( [olen, ooffset: nat] $BS.Bytestring_vtype( olen, ooffset, cap, 0, 1, dynamic, p), n)
    , orig: !$BS.Bytestring_vtype( len, offset, cap, ucap, refcnt, dynamic, p) >> $BS.Bytestring_vtype( len, offset, cap, ucap, refcnt - n, dynamic, p)
    ):<!wrt> void = 
    case+ xs of
    | ~list_vt_nil() => ()
    | ~list_vt_cons( head, tail) => __freelin( tail, orig) where {
      val () = $BS.free( head, orig)
    }
  val i0 = $BS.split_on( '-', i)
  val result = case+ i0 of
    | list_vt_cons( year_s, list_vt_cons( month_s, list_vt_cons( day_s, list_vt_nil()))) =>
        ( if day_sz > 0
        then Some_vt(1)
        else None_vt()
        ) where {
      val day_sz = length day_s
      val () = ( free( year_s, i); free( month_s, i); free( day_s, i))
    }
    | others => None_vt()
  val () = __freelin( i0, i)
in
  result
end

implement main0() = {
  val s = $BS.pack "2020-12-20"
  val () = free s where {
    val () =
      case+ test1( s) of
      | ~None_vt() => println!( "None")
      | ~Some_vt(some) => println!( "some ", some)
  }
}