#include "poke.h"

VALUE rb_mPoke;

void
Init_poke(void)
{
  rb_mPoke = rb_define_module("Poke");
}
