
#include "share/atspre_staload.hats"

#define ATS_DYNLOADFLAG 0

#define LIBS_targetloc "../libs" (* search path for external libs *)
#include "{$LIBS}/ats-bytestring/HATS/bytestring.hats"

staload UN="prelude/SATS/unsafe.sats"


extern fn
  get_yday_from_date
  ( year: uint32
  , month: uint32
  , day: uint32
  ):<> uint32
implement get_yday_from_date( year0, month0, day0) =
let
  fn is_leap
    ( year: uint
    ):<> bool =
  (year % 4u) = 0 
  && ( (year % 100u) <> 0
     || (year % 400u) = 0
     )
  var dpm = @[int](31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  fun
    sum
    {n:nat | n < 12}
    .<n>.
    ( i: uint n
    , acc: uint
    , dpm: &(@[int][12])
    ):<> uint =
  if i = 0u
  then acc
  else sum( newi
          , acc + (($UN.cast{uint} (array_get_at_guint( dpm, newi))))
          , dpm
          ) where {
    val newi = i - 1u
  }
  val year = g1ofg0 (g0uint2uint_uint32_uint( year0)) 
  val month = g1ofg0 ((g0uint2uint_uint32_uint( month0)) - 1u)
  val day = g1ofg0 ((g0uint2uint_uint32_uint( day0)))
in
  if month > 11u
  then $UN.cast{uint32} 0
  else
  let
    val days_per_months =
      if month > 0u
      then sum( month, 0u, dpm)
      else 0u
    val whole_days =
      if month > 1u && is_leap( year)
      then day + 1u
      else day
  in
    $UN.cast{uint32} (g0uint_add_uint(days_per_months, whole_days))
  end
end

fn
  lora_timestamp2timespec
  {offset,cap,ucap:nat}{len:pos}{dynamic:bool}{p:agz}
  ( i: !$BS.Bytestring_vtype( len, offset, cap, ucap, 0, dynamic, p)
  ):<!wrt> Option_vt( @(int32, uint32) ) =
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
in
  case+ $BS.split_on( 'T', i) of
  | ~list_vt_cons( date_s, ~list_vt_cons(time_s, ~list_vt_nil())) =>
    ( case+ ($BS.split_on( '-', date_s), $BS.split_on( ':', time_s)) of
    | ( ~list_vt_cons( year_s, ~list_vt_cons( month_s, ~list_vt_cons( day_s, ~list_vt_nil())))
      , ~list_vt_cons( hour_s, ~list_vt_cons( minute_s, ~list_vt_cons( secs_nsecs, ~list_vt_nil())))
      ) =>
        ( case+ $BS.split_on( '.', secs_nsecs) of
        | ~list_vt_cons( secs_s, ~list_vt_cons( nsecs_z_s, ~list_vt_nil())) => // truncate Z
        let
          val nsecs_sz = length nsecs_z_s
        in
          if nsecs_sz > 0
          then
          let
            fn __freelin_opt
              ( x: Option_vt( uint32)
              ):<> void =
              case+ x of
              | ~None_vt() => ()
              | ~Some_vt(_) => ()
            val nsecs_s = $BS.take( nsecs_sz - 1, nsecs_z_s) // remove the Z
            val oyear = $BS.parse_uint32 year_s
            val omonth = $BS.parse_uint32 month_s
            val oday = $BS.parse_uint32 day_s
            val ohour = $BS.parse_uint32 hour_s
            val ominute = $BS.parse_uint32 minute_s
            val osec = $BS.parse_uint32 secs_s
            val onsecs = $BS.parse_uint32 nsecs_s
            val () = free( nsecs_s, nsecs_z_s)
            val () = free( secs_s, secs_nsecs)
            val () = free( nsecs_z_s, secs_nsecs)
            val () = free( year_s, date_s)
            val () = free( month_s, date_s)
            val () = free( day_s, date_s)
            val () = free( hour_s, time_s)
            val () = free( minute_s, time_s)
            val () = free( secs_nsecs, time_s)
            val () = free( date_s, i)
            val () = free( time_s, i)
          in
            case+ ( oyear, omonth, oday, ohour, ominute, osec, onsecs) of
            | ( ~Some_vt( year), ~Some_vt( month), ~Some_vt( day), ~Some_vt( hour), ~Some_vt( minute), ~Some_vt( sec), ~Some_vt( nsecs)) => Some_vt( @(secs, nsecs) ) where {
              val year_i32 = $UN.cast{int32} (year - $UN.cast{uint32} 1900)
              val yday = get_yday_from_date( year, month, day) - $UN.cast{uint32}1
              val secs_per_day = $UN.cast{int32}86400
              val expr1 = (year_i32 - ($UN.cast{int32}70))*($UN.cast{int32}31536000)
              val expr2 = ((year_i32 - ($UN.cast{int32}69)) / ($UN.cast{int32}4))* secs_per_day
              val expr3 = ((year_i32 - ($UN.cast{int32}1))/($UN.cast{int32}100))* secs_per_day
              val expr4 = ((year_i32 + ($UN.cast{int32}299))/($UN.cast{int32}400)) * secs_per_day
              val secs = ($UN.cast{int32} sec)
                        + ($UN.cast{int32} minute) * ($UN.cast{int32} 60)
                        + ($UN.cast{int32} hour) * ($UN.cast{int32} 3600)
                        + ($UN.cast{int32} yday) * secs_per_day
                        + expr1
                        + expr2
                        - expr3
                        + expr4
            }
            | ( oyear, omonth, oday, ohour, ominute, osec, onsecs) => None_vt() where {
              val () = __freelin_opt( oyear)
              val () = __freelin_opt( omonth)
              val () = __freelin_opt( oday)
              val () = __freelin_opt( ohour)
              val () = __freelin_opt( ominute)
              val () = __freelin_opt( osec)
              val () = __freelin_opt( onsecs)
            }
          end
          else None_vt() where {
            val () = free( secs_s, secs_nsecs)
            val () = free( nsecs_z_s, secs_nsecs)
            val () = free( year_s, date_s)
            val () = free( month_s, date_s)
            val () = free( day_s, date_s)
            val () = free( hour_s, time_s)
            val () = free( minute_s, time_s)
            val () = free( secs_nsecs, time_s)
            val () = free( date_s, i)
            val () = free( time_s, i)
          }
        end
        | others => None_vt() where {
          val () = __freelin( others, secs_nsecs)
          val () = free( year_s, date_s)
          val () = free( month_s, date_s)
          val () = free( day_s, date_s)
          val () = free( hour_s, time_s)
          val () = free( minute_s, time_s)
          val () = free( secs_nsecs, time_s)
          val () = free( date_s, i)
          val () = free( time_s, i)
        }
        )
    | ( some_date_s, some_time_s) => None_vt() where {
      val () = __freelin( some_date_s, date_s)
      val () = __freelin( some_time_s, time_s)
      val () = free( date_s, i)
      val () = free( time_s, i)
    }
    )
  | others => None_vt() where {
    val () = __freelin( others, i)
  }
end

implement main0() = {
  val s = $BS.pack "2020-12-18T13:27:59.862974379Z"
  val () = free s where {
    val () =
      case+ lora_timestamp2timespec( s) of
      | ~None_vt() => println!( "None")
      | ~Some_vt( @(first, second) ) => println!( "some ", first, ", ", second)
  }
}