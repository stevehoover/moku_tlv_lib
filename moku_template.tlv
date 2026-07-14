\m4_TLV_version 1d: tl-x.org
\m4
\SV
   // Include the Moku library (instrument macros and the moku_go platform
   // model).
   //
   // See README.md ("Using the library") for how to make moku_lib.tlv
   // accessible. To include a local copy with sandpiper_saas, REPLACE the URL
   // below with a relative path (see README) -- do NOT merely comment this line
   // out, because library includes are processed by M4 even inside "//" comments.
   // Once your changes are pushed, pin the URL to a commit SHA for reproducibility
   // (.../moku_tlv_lib/<commit-sha>/moku_lib.tlv).
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/moku_tlv_lib/refs/heads/main/moku_lib.tlv'])

   // Sort-example visualization used below.
   m4_def(examples, ['['https://raw.githubusercontent.com/stevehoover/makerchip_examples/44557dbd6527de0c4c5ff60835bff37939cb24dd']'])
   m4_include_lib(m4_examples/sort_viz.tlv)

   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)

\TLV
   // 8-bit values: | slot1 | slot2 | slot3 | slot4 |
   //               | a | b | a | b | a | b | a | b |
   //          (MSB)  0   1   0   0   0   0   0   0  (LSB)
   m4+moku_go(/top, 00000100, 00000000, 10000000, 00000000)
   //               from_bus1,from_bus2,to_bus1,  to_bus2

   // Configure the instruments:
   /instrument1
      m4+noise_instrument(a)
      m4+const_instrument(b, 0)
   /instrument2
      m4+lag_instrument(a)
      m4+const_instrument(b, 0)
      //m4+cap_instrument(b, 16'h2000)
   /instrument3
      m4+cap_instrument(a, 16'h2000)
      m4+half_instrument(b)
   /instrument4
      m4+const_instrument(a, 0)
      m4+const_instrument(b, 0)
   
   m4+sort_example(/sort, ['left:335, top:100, width:30, height:70'])
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
