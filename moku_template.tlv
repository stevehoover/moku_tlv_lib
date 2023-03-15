\m4_TLV_version 1d: tl-x.org
\m4
   m4_def(a_color, "rgb(255, 0, 0)")
   m4_def(b_color, "rgb(0, 0, 255)")
   m4_def(fade_a_color, "rgb(150, 50, 50)")
   m4_def(fade_b_color, "rgb(50, 50, 150)")
   m4_def(bus1_color, "rgb(0, 150, 150)")
   m4_def(bus2_color, "rgb(0, 150, 0)")
\SV
   m4_include_lib(['https://raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/3760a43f58573fbcf7b7893f13c8fa01da6260fc/tlv_lib/fpga_includes.tlv'])                   
   m4_def(examples, ['['https://raw.githubusercontent.com/stevehoover/makerchip_examples/44557dbd6527de0c4c5ff60835bff37939cb24dd']'])
   m4_include_lib(m4_examples/sort_viz.tlv)

   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV schmitt_trigger_instrument(#_high, #_low)
   $out_a[15:0] = $reset ? 16'h8000 :
                  ($in_a > #_high) ? 16'h7fff :
                  ($in_a < #_low) ? 16'h8000 :
                  $RETAIN;

\TLV const(_which, #_val)
   $out_['']_which[15:0] = #_val;

\TLV half(_which)
   $out_['']_which[15:0] = {$in_['']_which[15], $in_['']_which[15:1]};

\TLV shift(_which, #_amt)
   $out_['']_which[15:0] = $in_['']_which + #_amt;

\TLV cap(_which, #_amt)
   $out_['']_which[15:0] = (\$signed($in_['']_which) >  \$signed(#_amt)) ?  #_amt :
                           (\$signed($in_['']_which) < -\$signed(#_amt)) ? -#_amt :
                                                                 $in_['']_which;
\TLV lag(_which)
   $out_['']_which[15:0] =
      $reset ? 16'h0000 :
               {>>1$out_['']_which[15], >>1$out_['']_which[15:1]} + {$in_['']_which[15], $in_['']_which[15:1]}; 

\TLV noise(_which)
   m4_rand($out_['']_which, 15, 0) 

// #_from/to_bus_1/2 are, e.g.: 10000000, 10000000, 01000000, 01000000
//                              from_bus1,from_bus2,to_bus1,  to_bus2
//   Each "1" indicates an input or output slot connection with a bus. 
//   Each value (8 bits) indicates, for that bus and direction:
//    (MSB)  0   1   0   0   0   0   0   0  (LSB)
//         | slot1 | slot2 | slot3 | slot4 |
//         | a | b | a | b | a | b | a | b |
\TLV moku_go(/_top, #_from_bus1, #_from_bus2, #_to_bus1, #_to_bus2)
   // Combine connections for buses 1 & 2 into 16 bit values for easier elaboration-time manipulation.
   m4_def(from_bus, #_from_bus1['']#_from_bus2)
   m4_def(to_bus, #_to_bus1['']#_to_bus2)
   // bus_connection(port#(0/1)(for a/b), from/to(0/1), bus#(1/2) [...])
   m4_def(bus_connection_generic, ['((((($']['2) ? $']['4['']m4_to_bus : $']['4['']m4_from_bus) >> (15 - ((8 * ($']['3 - 1)) + (($']['5 - 1) * 2) + ($']['1)))) & 1) != 0)'])
   m4_def(bus_connection, ['m4_bus_connection_generic($']['1, $']['2, $']['3, 16'b, #slot)'])
   m4_def(bus_connection_js, ['m4_bus_connection_generic($']['1, $']['2, $']['3, 0b, this.getIndex("slot"))'])
   /moku_go
      /bus[2:1]
         $value[15:0] =
            m4_bus_connection_generic(0, 1, #bus, 16'b, 1) ? /moku_go/slot[1]$out_a :
            m4_bus_connection_generic(1, 1, #bus, 16'b, 1) ? /moku_go/slot[1]$out_b :
            m4_bus_connection_generic(0, 1, #bus, 16'b, 2) ? /moku_go/slot[2]$out_a :
            m4_bus_connection_generic(1, 1, #bus, 16'b, 2) ? /moku_go/slot[2]$out_b :
            m4_bus_connection_generic(0, 1, #bus, 16'b, 3) ? /moku_go/slot[3]$out_a :
            m4_bus_connection_generic(1, 1, #bus, 16'b, 3) ? /moku_go/slot[3]$out_b :
            m4_bus_connection_generic(0, 1, #bus, 16'b, 4) ? /moku_go/slot[4]$out_a :
            m4_bus_connection_generic(1, 1, #bus, 16'b, 4) ? /moku_go/slot[4]$out_b :
                                                             16'b0;
         \viz_js
            box: {left: -30, top: -10, width: 420, height: 20, strokeWidth: 0},
            init() {
               return {
                  label: new fabric.Text("Bus " + this.getIndex(), {left: -30, top: -6, fontSize: 12}),
                  line: new fabric.Line([0, 0, 400, 0], {stroke: (this.getIndex("bus") == 1) ? m4_bus1_color : m4_bus2_color, strokeWidth: 2}),
               }
            },
            render() {
            },
            where: {left: -30, top: 0},
      /slot[4:1]
         $reset = /_top$reset;
         
         // Connect slot inputs.
         $in_a[15:0] = m4_bus_connection(0, 0, 1) ? /moku_go/bus[1]$value :
                       m4_bus_connection(0, 0, 2) ? /moku_go/bus[2]$value :
                                                 /slot[((#slot + 2) % 4) + 1]$out_a;
         $in_b[15:0] = m4_bus_connection(1, 0, 1) ? /moku_go/bus[1]$value :
                       m4_bus_connection(1, 0, 2) ? /moku_go/bus[2]$value :
                                                 /slot[((#slot + 2) % 4) + 1]$out_b;
         // Connect slot output from instruments.
         $out_a[15:0] = (#slot == 1) ? /_top/instrument1$out_a :
                        (#slot == 2) ? /_top/instrument2$out_a :
                        (#slot == 3) ? /_top/instrument3$out_a :
                                       /_top/instrument4$out_a;
         $out_b[15:0] = (#slot == 1) ? /_top/instrument1$out_b :
                        (#slot == 2) ? /_top/instrument2$out_b :
                        (#slot == 3) ? /_top/instrument3$out_b :
                                       /_top/instrument4$out_b;
         
         \viz_js
            box: {width: 50, height: 100, stroke: "black", strokeWidth: 1, rx: 4, ry: 4},
            layout: {left: 100, top: 0},
            init() {
               return {
                  title: new fabric.Text("Title", {left: 8, top: 5, fontSize: 12}),
                  // pins
                  in_a:  new fabric.Circle({radius: 3, left: 0, top: 25, originX: "center", originY: "center", fill: m4_a_color}),
                  in_b:  new fabric.Circle({radius: 3, left: 0, top: 75, originX: "center", originY: "center", fill: m4_b_color}),
                  out_a: new fabric.Circle({radius: 3, left: 50, top: 25, originX: "center", originY: "center", fill: m4_a_color}),
                  out_b: new fabric.Circle({radius: 3, left: 50, top: 75, originX: "center", originY: "center", fill: m4_b_color}),
               }
            },
            render() {
               debugger
               let ret = []
               ret.push(new fabric.Text(`Slot ${this.getIndex()}`, {left: 10, top: -14, fontSize: 12}))
               let port = 1;
               for (port = 1; port <= 2; port++) {
                  let in_bus = 0
                  if ((port == 1) ? m4_bus_connection_js(0, 0, 1) : m4_bus_connection_js(1, 0, 1)) {in_bus = 1}
                  if ((port == 1) ? m4_bus_connection_js(0, 0, 2) : m4_bus_connection_js(1, 0, 2)) {in_bus = 2}
                  let out_bus = 0
                  if ((port == 1) ? m4_bus_connection_js(0, 1, 1) : m4_bus_connection_js(1, 1, 1)) {out_bus = 1}
                  if ((port == 1) ? m4_bus_connection_js(0, 1, 2) : m4_bus_connection_js(1, 1, 2)) {out_bus = 2}
                  if (in_bus) {
                     let bus_color = (in_bus == 1) ? m4_bus1_color : m4_bus2_color
                     ret.push(new fabric.Circle({radius: 15, left: -15, top: -55 + 50 * port, startAngle: Math.PI / 2, endAngle: Math.PI, stroke: bus_color, strokeWidth: 2, fill: "",}))
                     ret.push(new fabric.Text(`${in_bus}`, {left: -23, top: -39 + 50 * port, fontSize: 12, fill: bus_color}))
                     ret.push(new fabric.Triangle({left: -15, top: -69 + in_bus * 20, originX: "center", originY: "bottom", width: 10, height: -6, fill: bus_color}))
                  } else {
                     ret.push(new fabric.Line([0, -25 + 50 * port, -50, -25 + 50 * port], {stroke: (port == 1) ? m4_a_color : m4_b_color, strokeWidth: 2}))
                  }
                  if (out_bus) {
                     let bus_color = (out_bus == 1) ? m4_bus1_color : m4_bus2_color
                     ret.push(new fabric.Circle({radius: 15, left: 35, top: -55 + 50 * port, startAngle: 0, endAngle: Math.PI / 2, stroke: bus_color, strokeWidth: 2, fill: "",}))
                     ret.push(new fabric.Text(`${out_bus}`, {left: 68, top: -39 + 50 * port, fontSize: 12, fill: bus_color}))
                     ret.push(new fabric.Triangle({left: 65, top: -70 + out_bus * 20, originX: "center", width: 10, height: 6, fill: bus_color}))
                  }
               }
               return ret
            },
            where: {left: 25, top: 60},
         /plot
            // Viz of the plot of inputs and outputs over time.
            \viz_js
               box: {left: -100, top: -40, width: 100, height: 80},
               render() {
                  let history = 20
                  let ret = []
                  // Input/output value to Y
                  function y(v) {
                     return -((v >= 0x8000) ? (v - 0x10000) : v) / 0x8000 * 40
                  }
                  // Time to X
                  function x(t) {
                     return -t * 100 / history
                  }
                  let plot =
                     [{sig: '/slot[this.getIndex("slot")]$in_a', color: m4_fade_a_color},
                      {sig: '/slot[this.getIndex("slot")]$in_b', color: m4_fade_b_color},
                      {sig: '/slot[this.getIndex("slot")]$out_a', color: m4_a_color},
                      {sig: '/slot[this.getIndex("slot")]$out_b', color: m4_b_color},
                     ]
                  plot.forEach(el => {
                     let time = 0
                     for (time = 0; time < history; time++) {
                        let val1 = el.sig.asInt()
                        el.sig.step(-1)
                        let val2 = el.sig.asInt()
                        ret.push(new fabric.Line([x(time), y(val1), x(time + 1), y(val2)], {stroke: el.color, strokeWidth: 1}))
                     }
                  })
                  return ret
               },
               where: {left: 55, top: 35, width: 35, height: 30, justifyY: "center"},
\TLV
   $reset = *reset;
   /instrument1
      $ANY = /top/moku_go/slot[1]$ANY;
      `BOGUS_USE($in_a)
   /instrument2
      $ANY = /top/moku_go/slot[2]$ANY;
      `BOGUS_USE($in_a)
   /instrument3
      $ANY = /top/moku_go/slot[3]$ANY;
      `BOGUS_USE($in_a)
   /instrument4
      $ANY = /top/moku_go/slot[4]$ANY;
      `BOGUS_USE($in_a)


   // Configure the instruments:
   /instrument1
      m4+noise(a)
      m4+const(b, 0)
   /instrument2
      m4+lag(a)
      m4+const(b, 0)
      //m4+cap(b, 16'h2000)
   /instrument3
      m4+cap(a, 16'h2000)
      m4+half(b)
   /instrument4
      m4+const(a, 0)
      m4+const(b, 0)
   
   m4+sort_example(/sort, ['left:335, top:100, width:30, height:70'])
   
   // 8-bit values: | slot1 | slot2 | slot3 | slot4 |
   //               | a | b | a | b | a | b | a | b |
   //          (MSB)  0   1   0   0   0   0   0   0  (LSB)
   m4+moku_go(/top, 00000100, 00000000, 10000000, 00000000)
   //               from_bus1,from_bus2,to_bus1,  to_bus2

   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
