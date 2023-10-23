package constants_pkg;
    localparam int unsigned INV_DELAY = 10;
    localparam int unsigned FIRO_LENGTH = 10;
    localparam int unsigned GARO_LENGTH = 11;

    //////////////* best FiRO/GaRO polynomials * //////////////
    // Ref.: "Experimental Assessment of FIRO- and GARO-based
    //        Noise Sources for Digital TRNG Designs on FPGAs"
    //
    // poly0 -> lowest entropy     poly2 -> highest entropy
    //
    // poly[0] + poly[1]*x1 + poly[2]*x2 ...
    ///////////////////////////////////////////////////////////

    typedef logic[FIRO_LENGTH-1:0] poly_FIRO;
	localparam poly_FIRO poly0_FIRO = 10'b0001111110;
    localparam poly_FIRO poly1_FIRO = 10'b0111101110;
    localparam poly_FIRO poly2_FIRO = 10'b0011111110;
    localparam poly_FIRO[2 : 0] polyFIRO_array = {poly2_FIRO, poly1_FIRO, poly0_FIRO};

    typedef logic[GARO_LENGTH-1:0] poly_GARO;
    localparam poly_GARO poly0_GARO = 11'b01111111100;
    localparam poly_GARO poly1_GARO = 11'b01010111100;
    localparam poly_GARO poly2_GARO = 11'b01001111100;
    localparam poly_GARO[2 : 0] polyGARO_array = {poly2_GARO, poly1_GARO, poly0_GARO};

    localparam int unsigned N_FIROs_GAROs = 2;
    localparam int unsigned N_STAGES = 4;

endpackage