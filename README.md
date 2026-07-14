# moku_tlv_lib

TL-Verilog content for Liquid Instruments Moku products.

## Files

- `moku_lib.tlv` — the library: reusable instrument macros
  (`const_instrument`, `half_instrument`, `shift_instrument`, `cap_instrument`,
  `lag_instrument`, `noise_instrument`, `schmitt_trigger_instrument`)
  and the `moku_go` platform model (Moku:Go multi-instrument mode, with
  visualization).
- `moku_template.tlv` — a starting-point design that includes the library and
  instantiates a Moku:Go configuration.

## Using the library

`moku_template.tlv` includes the library from GitHub, so `moku_lib.tlv` must be
committed and pushed. Pin the URL to a commit SHA for reproducible builds:

```
m4_include_lib(['https://raw.githubusercontent.com/stevehoover/moku_tlv_lib/<commit-sha>/moku_lib.tlv'])
```

To compile locally against a working copy, replace that URL with a relative
path (`['./moku_lib.tlv']`) and provide `moku_lib.tlv` alongside the template.
