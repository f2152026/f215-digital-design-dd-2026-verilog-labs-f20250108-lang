// cla64_flat.v
module cla64_flat (
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    wire [63:0] p, g;
    wire [64:1] c; // c[1]..c[64]

    // Step 1: Generate and propagate signals
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_pg
            xor #(2) (p[i], a[i], b[i]);
            and #(2) (g[i], a[i], b[i]);
        end
    endgenerate

    // Step 2: 64 flat carry equations (2 time-unit delay)
    genvar k, j;
    generate
        assign #(2) c[1] = g[0] | (p[0] & cin);
        for (k = 2; k <= 64; k = k + 1) begin : gen_c
            wire [k-1:0] term;
            assign term[k-1] = g[k-1];
            assign term[k-2] = p[k-1] & g[k-2];
            for (j = 0; j < k-2; j = j + 1) begin : gen_terms
                assign term[j] = (&p[k-1:j+1]) & g[j];
            end
            assign #(2) c[k] = (|term) | ((&p[k-1:0]) & cin);
        end
    endgenerate

    assign cout = c[64];

    // Step 3: Sum computation
    assign #(2) sum = p ^ {c[63:1], cin};

endmodule