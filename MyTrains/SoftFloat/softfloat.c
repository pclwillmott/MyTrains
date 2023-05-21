
/*============================================================================

This C source file is part of the SoftFloat IEEE Floating-Point Arithmetic
Package, Release 3e, by John R. Hauser.

Copyright 2011, 2012, 2013, 2014, 2015, 2016, 2017 The Regents of the
University of California.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions, and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the University nor the names of its contributors may
    be used to endorse or promote products derived from this software without
    specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS", AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ARE
DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

#include "softfloat.h"

float16_t float_to_float16(float a) {

  union {
    float d;
    float32_t f;
  } param;
  
  param.d = a;
  
  return f32_to_f16(param.f);

}

float float16_to_float(float16_t a) {
  
  float32_t r = f16_to_f32(a);
  
  union {
    float d;
    float32_t f;
  } param;
  
  param.f = r;
  
  return param.d;
  
}

float16_t f32_to_f16( float32_t a )
{
  
    union ui32_f32 uA;
    uint_fast32_t uiA;
    bool sign;
    int_fast16_t exp;
    uint_fast32_t frac;
    struct commonNaN commonNaN;
    uint_fast16_t uiZ, frac16;
    union ui16_f16 uZ;

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    uA.f = a;
    uiA = uA.ui;
    sign = signF32UI( uiA );
    exp  = expF32UI( uiA );
    frac = fracF32UI( uiA );
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    if ( exp == 0xFF ) {
        if ( frac ) {
            softfloat_f32UIToCommonNaN( uiA, &commonNaN );
            uiZ = softfloat_commonNaNToF16UI( &commonNaN );
        } else {
            uiZ = packToF16UI( sign, 0x1F, 0 );
        }
        goto uiZ;
    }
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    frac16 = frac>>9 | ((frac & 0x1FF) != 0);
    if ( ! (exp | frac16) ) {
        uiZ = packToF16UI( sign, 0, 0 );
        goto uiZ;
    }
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    return softfloat_roundPackToF16( sign, exp - 0x71, frac16 | 0x4000 );
 uiZ:
    uZ.ui = uiZ;
    return uZ.f;

}

float32_t f16_to_f32( float16_t a )
{
    union ui16_f16 uA;
    uint_fast16_t uiA;
    bool sign;
    int_fast8_t exp;
    uint_fast16_t frac;
    struct commonNaN commonNaN;
    uint_fast32_t uiZ;
    struct exp8_sig16 normExpSig;
    union ui32_f32 uZ;

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    uA.f = a;
    uiA = uA.ui;
    sign = signF16UI( uiA );
    exp  = expF16UI( uiA );
    frac = fracF16UI( uiA );
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    if ( exp == 0x1F ) {
        if ( frac ) {
            softfloat_f16UIToCommonNaN( uiA, &commonNaN );
            uiZ = softfloat_commonNaNToF32UI( &commonNaN );
        } else {
            uiZ = packToF32UI( sign, 0xFF, 0 );
        }
        goto uiZ;
    }
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    if ( ! exp ) {
        if ( ! frac ) {
            uiZ = packToF32UI( sign, 0, 0 );
            goto uiZ;
        }
        normExpSig = softfloat_normSubnormalF16Sig( frac );
        exp = normExpSig.exp - 1;
        frac = normExpSig.sig;
    }
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    uiZ = packToF32UI( sign, exp + 0x70, (uint_fast32_t) frac<<13 );
 uiZ:
    uZ.ui = uiZ;
  
    return uZ.f;

}

/*----------------------------------------------------------------------------
| Raises the exceptions specified by 'flags'.  Floating-point traps can be
| defined here if desired.  It is currently not possible for such a trap
| to substitute a result value.  If traps are not implemented, this routine
| should be simply 'softfloat_exceptionFlags |= flags;'.
*----------------------------------------------------------------------------*/
void softfloat_raiseFlags( uint_fast8_t flags )
{

    softfloat_exceptionFlags |= flags;

}

uint_fast32_t
 softfloat_roundToUI32(
     bool sign, uint_fast64_t sig, uint_fast8_t roundingMode, bool exact )
{
    uint_fast16_t roundIncrement, roundBits;
    uint_fast32_t z;

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    roundIncrement = 0x800;
    if (
        (roundingMode != softfloat_round_near_maxMag)
            && (roundingMode != softfloat_round_near_even)
    ) {
        roundIncrement = 0;
        if ( sign ) {
            if ( !sig ) return 0;
            if ( roundingMode == softfloat_round_min ) goto invalid;
#ifdef SOFTFLOAT_ROUND_ODD
            if ( roundingMode == softfloat_round_odd ) goto invalid;
#endif
        } else {
            if ( roundingMode == softfloat_round_max ) roundIncrement = 0xFFF;
        }
    }
    roundBits = sig & 0xFFF;
    sig += roundIncrement;
    if ( sig & UINT64_C( 0xFFFFF00000000000 ) ) goto invalid;
    z = sig>>12;
    if (
        (roundBits == 0x800) && (roundingMode == softfloat_round_near_even)
    ) {
        z &= ~(uint_fast32_t) 1;
    }
    if ( sign && z ) goto invalid;
    if ( roundBits ) {
#ifdef SOFTFLOAT_ROUND_ODD
        if ( roundingMode == softfloat_round_odd ) z |= 1;
#endif
        if ( exact ) softfloat_exceptionFlags |= softfloat_flag_inexact;
    }
    return z;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
 invalid:
    softfloat_raiseFlags( softfloat_flag_invalid );
    return sign ? ui32_fromNegOverflow : ui32_fromPosOverflow;

}

int_fast32_t
 softfloat_roundToI32(
     bool sign, uint_fast64_t sig, uint_fast8_t roundingMode, bool exact )
{
    uint_fast16_t roundIncrement, roundBits;
    uint_fast32_t sig32;
    union { uint32_t ui; int32_t i; } uZ;
    int_fast32_t z;

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    roundIncrement = 0x800;
    if (
        (roundingMode != softfloat_round_near_maxMag)
            && (roundingMode != softfloat_round_near_even)
    ) {
        roundIncrement = 0;
        if (
            sign
                ? (roundingMode == softfloat_round_min)
#ifdef SOFTFLOAT_ROUND_ODD
                      || (roundingMode == softfloat_round_odd)
#endif
                : (roundingMode == softfloat_round_max)
        ) {
            roundIncrement = 0xFFF;
        }
    }
    roundBits = sig & 0xFFF;
    sig += roundIncrement;
    if ( sig & UINT64_C( 0xFFFFF00000000000 ) ) goto invalid;
    sig32 = sig>>12;
    if (
        (roundBits == 0x800) && (roundingMode == softfloat_round_near_even)
    ) {
        sig32 &= ~(uint_fast32_t) 1;
    }
    uZ.ui = sign ? -sig32 : sig32;
    z = uZ.i;
    if ( z && ((z < 0) ^ sign) ) goto invalid;
    if ( roundBits ) {
#ifdef SOFTFLOAT_ROUND_ODD
        if ( roundingMode == softfloat_round_odd ) z |= 1;
#endif
        if ( exact ) softfloat_exceptionFlags |= softfloat_flag_inexact;
    }
    return z;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
 invalid:
    softfloat_raiseFlags( softfloat_flag_invalid );
    return sign ? i32_fromNegOverflow : i32_fromPosOverflow;

}

/*----------------------------------------------------------------------------
| Converts the common NaN pointed to by 'aPtr' into a 16-bit floating-point
| NaN, and returns the bit pattern of this value as an unsigned integer.
*----------------------------------------------------------------------------*/
uint_fast16_t softfloat_commonNaNToF16UI( const struct commonNaN *aPtr )
{

    return (uint_fast16_t) aPtr->sign<<15 | 0x7E00 | aPtr->v64>>54;

}

/*----------------------------------------------------------------------------
| Assuming `uiA' has the bit pattern of a 32-bit floating-point NaN, converts
| this NaN to the common NaN form, and stores the resulting common NaN at the
| location pointed to by `zPtr'.  If the NaN is a signaling NaN, the invalid
| exception is raised.
*----------------------------------------------------------------------------*/
void softfloat_f32UIToCommonNaN( uint_fast32_t uiA, struct commonNaN *zPtr )
{

    if ( softfloat_isSigNaNF32UI( uiA ) ) {
        softfloat_raiseFlags( softfloat_flag_invalid );
    }
    zPtr->sign = uiA>>31;
    zPtr->v64  = (uint_fast64_t) uiA<<41;
    zPtr->v0   = 0;

}

float16_t
 softfloat_roundPackToF16( bool sign, int_fast16_t exp, uint_fast16_t sig )
{
    uint_fast8_t roundingMode;
    bool roundNearEven;
    uint_fast8_t roundIncrement, roundBits;
    bool isTiny;
    uint_fast16_t uiZ;
    union ui16_f16 uZ;

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    roundingMode = softfloat_roundingMode;
    roundNearEven = (roundingMode == softfloat_round_near_even);
    roundIncrement = 0x8;
    if ( ! roundNearEven && (roundingMode != softfloat_round_near_maxMag) ) {
        roundIncrement =
            (roundingMode
                 == (sign ? softfloat_round_min : softfloat_round_max))
                ? 0xF
                : 0;
    }
    roundBits = sig & 0xF;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    if ( 0x1D <= (unsigned int) exp ) {
        if ( exp < 0 ) {
            /*----------------------------------------------------------------
            *----------------------------------------------------------------*/
            isTiny =
                (softfloat_detectTininess == softfloat_tininess_beforeRounding)
                    || (exp < -1) || (sig + roundIncrement < 0x8000);
            sig = softfloat_shiftRightJam32( sig, -exp );
            exp = 0;
            roundBits = sig & 0xF;
            if ( isTiny && roundBits ) {
                softfloat_raiseFlags( softfloat_flag_underflow );
            }
        } else if ( (0x1D < exp) || (0x8000 <= sig + roundIncrement) ) {
            /*----------------------------------------------------------------
            *----------------------------------------------------------------*/
            softfloat_raiseFlags(
                softfloat_flag_overflow | softfloat_flag_inexact );
            uiZ = packToF16UI( sign, 0x1F, 0 ) - ! roundIncrement;
            goto uiZ;
        }
    }
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    sig = (sig + roundIncrement)>>4;
    if ( roundBits ) {
        softfloat_exceptionFlags |= softfloat_flag_inexact;
#ifdef SOFTFLOAT_ROUND_ODD
        if ( roundingMode == softfloat_round_odd ) {
            sig |= 1;
            goto packReturn;
        }
#endif
    }
    sig &= ~(uint_fast16_t) (! (roundBits ^ 8) & roundNearEven);
    if ( ! sig ) exp = 0;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
 packReturn:
    uiZ = packToF16UI( sign, exp, sig );
 uiZ:
    uZ.ui = uiZ;
    return uZ.f;

}

struct exp8_sig16 softfloat_normSubnormalF16Sig( uint_fast16_t sig )
{
    int_fast8_t shiftDist;
    struct exp8_sig16 z;

    shiftDist = softfloat_countLeadingZeros16( sig ) - 5;
    z.exp = 1 - shiftDist;
    z.sig = sig<<shiftDist;
    return z;

}

const uint_least8_t softfloat_countLeadingZeros8[256] = {
    8, 7, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

uint_fast8_t softfloat_countLeadingZeros16( uint16_t a )
{
    uint_fast8_t count;

    count = 8;
    if ( 0x100 <= a ) {
        count = 0;
        a >>= 8;
    }
    count += softfloat_countLeadingZeros8[a];
    return count;

}

THREAD_LOCAL uint_fast8_t softfloat_roundingMode = softfloat_round_near_even;
THREAD_LOCAL uint_fast8_t softfloat_detectTininess = init_detectTininess;
THREAD_LOCAL uint_fast8_t softfloat_exceptionFlags = 0;

THREAD_LOCAL uint_fast8_t extF80_roundingPrecision = 80;

uint32_t softfloat_shiftRightJam32( uint32_t a, uint_fast16_t dist )
{

    return
        (dist < 31) ? a>>dist | ((uint32_t) (a<<(-dist & 31)) != 0) : (a != 0);

}
