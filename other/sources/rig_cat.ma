//Maya ASCII 2018 scene
//Name: rig_cat.ma
//Last modified: Fri, Jul 13, 2018 02:48:32 AM
//Codeset: 1252
requires maya "2018";
requires -nodeType "aiOptions" -nodeType "aiAOVDriver" -nodeType "aiAOVFilter" "mtoa" "2.0.1";
requires -nodeType "ilrOptionsNode" -nodeType "ilrUIOptionsNode" -nodeType "ilrBakeLayerManager"
		 -nodeType "ilrBakeLayer" "Turtle" "2018.0.0";
requires "stereoCamera" "10.0";
currentUnit -l centimeter -a degree -t ntsc;
fileInfo "application" "maya";
fileInfo "product" "Maya 2018";
fileInfo "version" "2018";
fileInfo "cutIdentifier" "201706261615-f9658c4cfc";
fileInfo "osv" "Microsoft Windows 8 Business Edition, 64-bit  (Build 9200)\n";
fileInfo "license" "student";
createNode transform -s -n "persp";
	rename -uid "EAA5FA78-4027-DA51-79AA-5BBADD93C33C";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 229.50909903470449 -448.48174624082634 390.18875275967326 ;
	setAttr ".r" -type "double3" 75.682924916775832 3.1805546814635183e-15 2141.1953245949912 ;
	setAttr ".rp" -type "double3" 2.1316282072803006e-14 -7.1054273576010019e-15 7.1054273576010019e-15 ;
	setAttr ".rpt" -type "double3" -344.84976999191804 75.95338642854027 -228.45524763540641 ;
createNode camera -s -n "perspShape" -p "persp";
	rename -uid "21F02675-48A4-8821-E863-57BC704619A6";
	setAttr -k off ".v" no;
	setAttr ".pze" yes;
	setAttr ".fl" 34.999999999999993;
	setAttr ".coi" 396.63723349173165;
	setAttr ".imn" -type "string" "persp";
	setAttr ".den" -type "string" "persp_depth";
	setAttr ".man" -type "string" "persp_mask";
	setAttr ".tp" -type "double3" -1.0285198484936751 -0.8529493717483394 80.75593289927771 ;
	setAttr ".hc" -type "string" "viewSet -p %camera";
createNode transform -s -n "top";
	rename -uid "A7FC66BB-4060-EBDB-DFD3-F2BAA240CA40";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0 101.81344602108001 1100.2014744898811 ;
	setAttr ".r" -type "double3" 179.99999999999997 0 0 ;
	setAttr ".rp" -type "double3" 0 -1.7134460210799602 -1000.1014744898812 ;
	setAttr ".rpt" -type "double3" 0 -100.09999999999991 -100.0999999999998 ;
createNode camera -s -n "topShape" -p "top";
	rename -uid "D643541A-452A-6E10-9AFF-2AB960B4BEA9";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 995.56445886171775;
	setAttr ".ow" 17.13482738580479;
	setAttr ".imn" -type "string" "top";
	setAttr ".den" -type "string" "top_depth";
	setAttr ".man" -type "string" "top_mask";
	setAttr ".tp" -type "double3" 0 1.7134460210800171 4.5370156281634886 ;
	setAttr ".hc" -type "string" "viewSet -t %camera";
	setAttr ".o" yes;
createNode transform -s -n "front";
	rename -uid "0D87B50F-4816-6913-086B-72A802C902B9";
	setAttr ".v" no;
	setAttr ".t" -type "double3" -0.34499006573172208 -2097.8299989075404 -866.90226171985239 ;
	setAttr ".r" -type "double3" 269.99999999999994 0 0 ;
	setAttr ".rp" -type "double3" -0.49029198969346288 -4.7083818211081105 -1000.1121370445311 ;
	setAttr ".rpt" -type "double3" 0 2102.6910460829135 1884.4110105045147 ;
createNode camera -s -n "frontShape" -p "front";
	rename -uid "954838D6-43F4-C5A6-D6EC-E0B55BD23B60";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 993.55582122546775;
	setAttr ".ow" 106.3347927964537;
	setAttr ".imn" -type "string" "front";
	setAttr ".den" -type "string" "front_depth";
	setAttr ".man" -type "string" "front_mask";
	setAttr ".tp" -type "double3" -0.34499006573172214 6.7089811733286302 12.688229919023085 ;
	setAttr ".hc" -type "string" "viewSet -f %camera";
	setAttr ".o" yes;
createNode joint -n "j_root";
	rename -uid "868AC711-4AC9-495D-9E7E-3CA9AF138045";
	setAttr ".r" -type "double3" -1.3528616559792148e-09 8.1740258266043312e-13 2.5008001738317608e-09 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -89.982224208648134 -88.122645782500797 -0.017766250058816106 ;
createNode joint -n "j_pelvis" -p "j_root";
	rename -uid "42A56046-461E-F123-5A40-218CECB94CC3";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -4.3058195362372513e-05 -0.00057262739695904065 8.6004228750382055 ;
createNode joint -n "j_spine_01" -p "j_pelvis";
	rename -uid "B3DCB0CF-4320-C542-0972-E59E55672CD6";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -9.4787915988670522e-23 -9.0897980695097566e-06 -8.3166974990965645 ;
createNode joint -n "j_spine_02" -p "j_spine_01";
	rename -uid "72D5815F-490B-C57E-D9D4-609E06815497";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -6.1406620178765278e-05 -9.7855932796086701e-06 -9.0543685694733984 ;
createNode joint -n "j_spine_03" -p "j_spine_02";
	rename -uid "811F36BB-4596-18C9-1C2F-FCB986B366B6";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -9.2297311095732943e-05 -0.0020204221505627272 5.2311566360987092 ;
createNode joint -n "j_neck" -p "j_spine_03";
	rename -uid "CFD7022C-4D2E-950D-134D-ADB1696675EA";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.2094451744181604e-05 0.0020191704930718896 0.68705899313196961 ;
createNode joint -n "j_head" -p "j_neck";
	rename -uid "936137DA-420F-2C21-7BAF-F5851E5A8C14";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode joint -n "j_r_ear_01" -p "j_head";
	rename -uid "F049DEF5-4053-5436-187D-30855885FCF5";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 89.999882078317853 -27.904738481035423 -176.72190984925365 ;
	setAttr ".radi" 0.82655318707067649;
createNode joint -n "j_r_ear_02" -p "j_r_ear_01";
	rename -uid "1C208064-4FD8-6627-BD10-01816961D0BB";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".radi" 0.82655318707067649;
createNode parentConstraint -n "j_r_ear_02_parentConstraint1" -p "j_r_ear_02";
	rename -uid "B7275B95-4888-C09A-9179-C2BDE8F425E6";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_ear_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -7.1054273576010019e-14 7.1054273576010019e-15 
		1.4654943925052066e-13 ;
	setAttr ".rst" -type "double3" -8.4454408262792384 -0.52916621476529002 -0.030270579238444562 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_ear_01_parentConstraint1" -p "j_r_ear_01";
	rename -uid "EFBE5A69-445C-E800-8991-1BA8F01BE3A8";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_ear_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -5.6843418860808015e-14 -7.1054273576010019e-15 
		9.9475983006414026e-14 ;
	setAttr ".tg[0].tor" -type "double3" -1.2011743105442613e-14 -1.3084190269611631e-15 
		-9.5416640443905503e-15 ;
	setAttr ".lr" -type "double3" 1.9083328088781101e-14 -7.9513867036587935e-15 6.361109362927032e-15 ;
	setAttr ".rst" -type "double3" 27.418355863085836 -2.7953044747212044 -9.9156750924805408 ;
	setAttr ".rsrr" -type "double3" 1.9083328088781101e-14 -2.3835094009470856e-30 1.4312496066585827e-14 ;
	setAttr -k on ".w0";
createNode joint -n "j_l_ear_01" -p "j_head";
	rename -uid "827FD257-4D6D-B650-A233-B7B30AE5C7B1";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 90.000117921695107 -27.904750418311519 3.2779797753397095 ;
	setAttr ".radi" 0.82655318707067649;
createNode joint -n "j_l_ear_02" -p "j_l_ear_01";
	rename -uid "525DE1B9-4E18-982C-E7A5-928E9ED2A7FD";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".radi" 0.82655318707067649;
createNode parentConstraint -n "j_l_ear_02_parentConstraint1" -p "j_l_ear_02";
	rename -uid "94F1C2AC-47E5-0F64-43EB-9580574BEB22";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_ear_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.4210854715202004e-14 -2.8421709430404007e-14 
		1.8740564655672642e-13 ;
	setAttr ".rst" -type "double3" 8.445453072367485 0.52919787198104018 0.030274282279987297 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_ear_01_parentConstraint1" -p "j_l_ear_01";
	rename -uid "8C6CB7F7-464D-2E37-E105-A593B7D21885";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_ear_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.4210854715202004e-14 -4.2632564145606011e-14 
		1.3145040611561853e-13 ;
	setAttr ".tg[0].tor" -type "double3" -5.3046047679239814e-16 2.3949160351896861e-15 
		1.9083328088781101e-14 ;
	setAttr ".lr" -type "double3" 5.9635400277440928e-15 -3.1805546814635152e-15 -9.5416640443905487e-15 ;
	setAttr ".rst" -type "double3" 27.418378696618433 -2.7953364177248252 9.9156641699556882 ;
	setAttr ".rsrr" -type "double3" 5.9635400277440928e-15 -3.1805546814635152e-15 -9.5416640443905487e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_head_parentConstraint1" -p "j_head";
	rename -uid "E4E6F740-4C38-492B-87C1-1EA959E82D2A";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_headW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.4210854715202004e-14 -8.8817841970012523e-16 
		1.3004327432605822e-16 ;
	setAttr ".rst" -type "double3" 0.99985519321462846 0.017017420539295447 3.1020996455616199e-08 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_neck_parentConstraint1" -p "j_neck";
	rename -uid "AC6E4183-40D2-8B4F-4EC5-549BBEB8A19F";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_neckW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 7.1054273576010019e-15 -4.4408920985006262e-16 
		-1.0926725019580474e-19 ;
	setAttr ".tg[0].tor" -type "double3" -1.2073661621962303e-08 3.550055640995106e-10 
		-1.6145273888894366e-09 ;
	setAttr ".lr" -type "double3" 1.2073661621960328e-08 -3.5500556367556084e-10 1.6145272650623871e-09 ;
	setAttr ".rst" -type "double3" 7.2196606895051261 -0.012756957762636745 -1.2552242704998336e-05 ;
	setAttr ".rsrr" -type "double3" 1.2073661621957295e-08 -3.5500556367555169e-10 1.6145273644547208e-09 ;
	setAttr -k on ".w0";
createNode joint -n "j_l_clavicle" -p "j_spine_03";
	rename -uid "C17B5997-45A4-9682-C601-6FAD303959ED";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 179.99900720544809 -81.25952015374753 -178.33688630493313 ;
createNode joint -n "j_l_shoulder" -p "j_l_clavicle";
	rename -uid "4CD17C80-40AA-AC11-878A-BAAE2D5EAAAC";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.82766214234402258 -14.017145625753072 3.4132886617115128 ;
createNode joint -n "j_l_elbow" -p "j_l_shoulder";
	rename -uid "C20B748A-405D-107D-F9FE-CB95A19B3F5F";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.18678661638172536 -2.0409997214780704 1.9185657772405322 ;
createNode joint -n "j_l_wrist" -p "j_l_elbow";
	rename -uid "4E92FDE4-4DD8-7B13-06AA-25A841D7E0E7";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 179.99999999999889 24.833093124436282 0 ;
createNode parentConstraint -n "j_l_wrist_parentConstraint1" -p "j_l_wrist";
	rename -uid "A783DA8C-4194-0662-90F9-DF9856FED74E";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_wristW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 5.3529873866864364e-09 1.3266356901908694e-09 
		-6.2308558312906825e-09 ;
	setAttr ".rst" -type "double3" 6.2112901117607082 5.9952043329758453e-15 -7.1054273576010019e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_elbow_parentConstraint1" -p "j_l_elbow";
	rename -uid "1AE0C6AF-4524-304D-81E4-1EB18819C35C";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_elbowW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 3.5123717267993015e-09 -7.3818595680563703e-10 
		4.7216133225447265e-09 ;
	setAttr ".tg[0].tor" -type "double3" 1.2424041724466862e-16 0 -4.4804200468858623e-16 ;
	setAttr ".lr" -type "double3" -9.9392333795734899e-17 -3.9562807866349167e-16 1.9412565194479476e-18 ;
	setAttr ".rst" -type "double3" 10.564649377933483 -1.4432899320127035e-15 -3.5527136788005009e-14 ;
	setAttr ".rsrr" -type "double3" -9.9392333795734899e-17 -3.9562807866349167e-16 
		1.9412565194479476e-18 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_shoulder_parentConstraint1" -p "j_l_shoulder";
	rename -uid "D30B447F-4D0A-B433-68C2-238D37733151";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_shoulderW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.3809913212980973e-09 -2.5668345227103373e-10 
		3.7635672356373107e-09 ;
	setAttr ".tg[0].tor" -type "double3" -1.987846675914698e-16 1.5902773407317584e-15 
		-7.9513867036587919e-16 ;
	setAttr ".lr" -type "double3" 1.987846675914698e-16 -4.6590156466750749e-18 7.8271462864141232e-16 ;
	setAttr ".rst" -type "double3" 3.9696734274416121 -1.2088055249459709e-16 2.8421709430404007e-14 ;
	setAttr ".rsrr" -type "double3" 1.987846675914698e-16 -4.6590156466750749e-18 7.8271462864141232e-16 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_clavicle_parentConstraint1" -p "j_l_clavicle";
	rename -uid "AE3B377D-468C-6EA6-0DFA-20B57182415C";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_clavicleW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -4.3576076080853454e-10 -8.3849973543089959e-11 
		-1.361399881716352e-11 ;
	setAttr ".tg[0].tor" -type "double3" -2.0560032017863759e-10 2.5444437451708128e-14 
		-1.3370100016313099e-09 ;
	setAttr ".lr" -type "double3" 2.0560824948354856e-10 1.3205200948960186e-14 1.3369960553047548e-09 ;
	setAttr ".rst" -type "double3" 1.2149337689254622 -1.3625424714936178 3.5518677690090521 ;
	setAttr ".rsrr" -type "double3" 2.0559473212615187e-10 -1.8550649698630453e-14 1.3370022176294495e-09 ;
	setAttr -k on ".w0";
createNode joint -n "j_r_clavicle" -p "j_spine_03";
	rename -uid "569C8AE0-409D-9D30-FDC8-E8A048761B08";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -179.99900768830767 -81.255486363918266 1.6611516529305284 ;
createNode joint -n "j_r_shoulder" -p "j_r_clavicle";
	rename -uid "436414AF-4A8A-A75A-886F-C5BF63788008";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.82766214234671698 -14.01714562575304 3.4132886617116291 ;
createNode joint -n "j_r_elbow" -p "j_r_shoulder";
	rename -uid "DAD889A8-45EC-90EF-4AAD-EE8F7B48BE43";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.186786616391278 -2.0409997214781423 1.9185657772404558 ;
createNode joint -n "j_r_wrist" -p "j_r_elbow";
	rename -uid "6FCF803B-4349-823A-77E6-A9B40ED529BD";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 179.99999829245391 24.833093124436278 5.4417771727785033e-12 ;
createNode parentConstraint -n "j_r_wrist_parentConstraint1" -p "j_r_wrist";
	rename -uid "5A0C3389-4332-D9F4-CDEC-2480F33DF7C4";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_wristW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -5.7077897963608848e-11 1.0801854966047131e-09 
		-2.957420974780689e-09 ;
	setAttr ".tg[0].tor" -type "double3" 0 0 9.4787915988669299e-23 ;
	setAttr ".rst" -type "double3" -6.2112473297329371 2.1942846650802039e-08 3.3308461468095629e-05 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_elbow_parentConstraint1" -p "j_r_elbow";
	rename -uid "9237E707-4613-EBB3-1F22-83A728CC25A9";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_elbowW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.2266996307630507e-09 -5.4877413724341295e-10 
		2.7136479729961138e-09 ;
	setAttr ".tg[0].tor" -type "double3" 7.4544250346801174e-17 3.975693351829396e-16 
		-1.1531063725520806e-15 ;
	setAttr ".lr" -type "double3" -6.2120208622334312e-17 3.8825130388958988e-19 7.9630342427754799e-16 ;
	setAttr ".rst" -type "double3" -10.564651430038396 -3.547902940326253e-07 4.5915707524102345e-05 ;
	setAttr ".rsrr" -type "double3" -6.2120208622334312e-17 3.8825130388958988e-19 7.9630342427754799e-16 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_shoulder_parentConstraint1" -p "j_r_shoulder";
	rename -uid "A14AD1FD-4A33-5D9B-2951-A19B4E065030";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_shoulderW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.1483134443324161e-09 -2.4323465463993443e-10 
		2.7629667442852224e-09 ;
	setAttr ".tg[0].tor" -type "double3" 7.2741740555715378e-10 -1.0307207653445411e-09 
		1.5482514541694919e-09 ;
	setAttr ".lr" -type "double3" -7.2741611347074035e-10 1.0307214331269556e-09 -1.5482340232454951e-09 ;
	setAttr ".rst" -type "double3" -3.9696869690919678 7.2662051363913987e-18 -3.1958979661794729e-05 ;
	setAttr ".rsrr" -type "double3" -7.2742361759194184e-10 1.0307216489946799e-09 -1.5482524853714975e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_clavicle_parentConstraint1" -p "j_r_clavicle";
	rename -uid "B97CF377-4851-64B3-342A-D3A74185DF76";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_clavicleW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.303857288803556e-08 -2.5130673009243765e-07 
		-1.5210282811040088e-08 ;
	setAttr ".tg[0].tor" -type "double3" -8.7424967396696402 2.0415662444846167e-10 
		-89.999999998672024 ;
	setAttr ".lr" -type "double3" -3.9756928058577508e-16 -2.0179347232013425e-10 -3.1003848250238764e-11 ;
	setAttr ".rst" -type "double3" 1.2146764025672567 -1.3625312271897869 -3.5519529748946992 ;
	setAttr ".rsrr" -type "double3" 3.5781240712458361e-15 -2.0176802788268254e-10 -3.1009016651596146e-11 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_spine_03_parentConstraint1" -p "j_spine_03";
	rename -uid "CE672DCA-4068-8B67-43B8-5A9067E2C216";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_spine_03W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.0031895153810168608 0.00039489879070586653 
		1.492098206262206e-07 ;
	setAttr ".tg[0].tor" -type "double3" 1.2062781842498108e-08 -3.727854292862875e-10 
		1.6140771321595212e-09 ;
	setAttr ".lr" -type "double3" -1.2062781842539758e-08 3.7278542819241114e-10 -1.61407595353155e-09 ;
	setAttr ".rst" -type "double3" 11.324315815748477 2.5856561336468076e-10 -4.7280159388290999e-15 ;
	setAttr ".rsrr" -type "double3" -1.2062781842600422e-08 3.727854281951795e-10 -1.6140759535315494e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_spine_02_parentConstraint1" -p "j_spine_02";
	rename -uid "41CE6D53-480B-7B92-65B5-3EB745BF71D6";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_spine_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.0035254685634100724 -0.0070991228587802269 
		2.4648032994912519e-08 ;
	setAttr ".tg[0].tor" -type "double3" 9.2665672687072476e-05 1.5708228261709116e-07 
		0.036426297075111969 ;
	setAttr ".lr" -type "double3" -5.5622767233776119e-21 -1.5708228261673548e-07 2.5455278565882602e-13 ;
	setAttr ".rst" -type "double3" 11.089088717430478 -1.4379608614945028e-11 -5.4809130324573463e-16 ;
	setAttr ".rsrr" -type "double3" -1.736337226396718e-20 -1.5708228261689549e-07 2.545527856587418e-13 ;
	setAttr -k on ".w0";
createNode joint -n "j_tail_01" -p "j_spine_01";
	rename -uid "B86FDC76-41ED-B47D-A96E-AF831B8541AF";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "xzy";
	setAttr ".jo" -type "double3" 6.4526235158522075e-05 -6.2137209040222555e-05 -92.16107948822787 ;
createNode joint -n "j_tail_02" -p "j_tail_01";
	rename -uid "EECD0EEF-4A50-1CB1-8F1B-71B30F14A89B";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -6.2180969713973255e-05 2.3696978997167331e-23 0.22160627633843005 ;
createNode joint -n "j_tail_03" -p "j_tail_02";
	rename -uid "262A147F-4C1A-DD3E-08F7-138C11337119";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode joint -n "j_tail_04" -p "j_tail_03";
	rename -uid "8B449638-4482-984C-5DCE-3C99E8FDCFB8";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode joint -n "j_tail_05" -p "j_tail_04";
	rename -uid "54C260F7-4AF8-105C-4AB6-D1B0C0D7DCE3";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode parentConstraint -n "j_tail_05_parentConstraint1" -p "j_tail_05";
	rename -uid "E5DEFA70-427D-C457-26F5-65B0D4BF29BC";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_tail_05W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.1249312592553906e-10 1.2264610660395192e-08 
		-1.2734631924985005e-09 ;
	setAttr ".rst" -type "double3" 14.702116910693192 -0.056864534679135659 1.4555276743542974e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_tail_04_parentConstraint1" -p "j_tail_04";
	rename -uid "C83F2499-43A0-FBD6-34C4-97961D0E3290";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_tail_04W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 9.822542779147625e-11 8.5709324082472449e-09 
		-9.263533108127589e-10 ;
	setAttr ".rst" -type "double3" 14.092836333001358 -0.055406428956711551 -1.2015398896046727e-13 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_tail_03_parentConstraint1" -p "j_tail_03";
	rename -uid "7A772986-4CF2-A82C-4966-AC8A98708DC3";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_tail_03W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 8.4313001025293488e-11 5.0303263776640961e-09 
		-5.9362816739442208e-10 ;
	setAttr ".rst" -type "double3" 12.267247986236525 4.3847556696618994e-09 6.8841802123751168e-10 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_tail_02_parentConstraint1" -p "j_tail_02";
	rename -uid "BCE24463-4FCA-6A70-15EB-2F832108D93C";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_tail_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 8.4321882809490489e-11 1.9483792357277707e-09 
		-3.040086954891807e-10 ;
	setAttr ".tg[0].tor" -type "double3" 1.213285324654967e-20 1.1848489498582266e-22 
		-1.2424041724464291e-16 ;
	setAttr ".lr" -type "double3" -2.4265799059423542e-20 -1.421818739830039e-22 1.242404172446347e-16 ;
	setAttr ".rst" -type "double3" 6.6487777639999912 -1.6704042593573831e-09 1.8128334662408097e-15 ;
	setAttr ".rsrr" -type "double3" -2.4265799059423542e-20 -9.4787915988669252e-23 
		9.9392333795712281e-17 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_tail_01_parentConstraint1" -p "j_tail_01";
	rename -uid "A7D4B93D-409C-992B-4572-02BF6540CA4E";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_tail_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -4.8494541715626838e-13 2.8421709430404007e-14 
		7.7992656050232837e-10 ;
	setAttr ".tg[0].tor" -type "double3" -2.1825725402359025e-07 -1.393412171749705e-08 
		1.4395578330446518e-08 ;
	setAttr ".lr" -type "double3" 2.1825725402008049e-07 1.3934121772283406e-08 -1.4395615630058366e-08 ;
	setAttr ".rst" -type "double3" -1.8890921886307019 -8.50080004328432 0.0002512810355726071 ;
	setAttr ".rsrr" -type "double3" 2.1825725402008049e-07 1.3934121772310966e-08 -1.4395577463402188e-08 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_spine_01_parentConstraint1" -p "j_spine_01";
	rename -uid "B7120822-4C64-08FD-3A7D-A69746F572F7";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_spine_01W0" -dv 1 -min 0 -at "double";
	addAttr -dcb 0 -ci true -k true -sn "w1" -ln "ctrl_j_pelvisW1" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr -s 2 ".tg";
	setAttr ".tg[0].tot" -type "double3" -0.0046459206297555511 0.032555443385711591 
		4.4542288874248369e-08 ;
	setAttr ".tg[0].tor" -type "double3" 7.6998482312223048e-05 5.228390254732345e-08 
		-0.20146742674009663 ;
	setAttr ".tg[1].tot" -type "double3" 8.5648695896722629 0.032885020525390551 1.1012228461878886e-08 ;
	setAttr ".tg[1].tor" -type "double3" 1.8901548722518131e-05 -6.4010599196088638e-06 
		-8.0967100618105459 ;
	setAttr ".lr" -type "double3" -2.9550385969389738e-15 -2.6141946335540971e-08 3.3395824390445123e-14 ;
	setAttr ".rst" -type "double3" 8.5649327176950862 -9.2707219678800357e-10 -4.2306571657393932e-14 ;
	setAttr ".rsrr" -type "double3" -2.955037554271898e-15 -2.614194633538386e-08 3.3395824390445041e-14 ;
	setAttr -k on ".w0";
	setAttr -k on ".w1";
createNode joint -n "j_l_femur" -p "j_pelvis";
	rename -uid "3431E8E4-4A67-3BC2-2A35-2C80017200FB";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 178.84700971335113 -4.2819297614784562 -175.39111592331969 ;
createNode joint -n "j_l_knee" -p "j_l_femur";
	rename -uid "07CCF783-4194-669B-B7D1-958DF812E191";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225637572013 178.04591234014012 17.576356065281974 ;
createNode joint -n "j_l_heel" -p "j_l_knee";
	rename -uid "3FB2E661-4CD2-C0E5-F9A1-FA9B4ECA56DD";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 0 0 179.99999999999997 ;
createNode joint -n "j_l_foot" -p "j_l_heel";
	rename -uid "6F3BD02D-45DB-C3B1-448F-D6B14DE1A8D8";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299210189117 5.4430146952341847 -23.175135144647015 ;
createNode joint -n "j_l_toe" -p "j_l_foot";
	rename -uid "B94303FD-4AD6-BD76-75DF-4FAF377B228E";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222922709 -89.999999999999815 0 ;
createNode parentConstraint -n "j_l_toe_parentConstraint1" -p "j_l_toe";
	rename -uid "585B5B1B-417E-46D4-8B2E-2E9C01FEBA1C";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_toeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -4.4408920985006262e-15 -6.4392935428259079e-15 
		-2.6645352591003757e-15 ;
	setAttr ".tg[0].tor" -type "double3" 3.180554681463286e-15 -2.2599200246016812e-29 
		0 ;
	setAttr ".rst" -type "double3" 5.1907966380376838 0.77791659223573961 -7.0447647715354833e-11 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_foot_parentConstraint1" -p "j_l_foot";
	rename -uid "768A292E-4D21-FE87-C380-49B17953F8AA";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_footW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -8.8817841970012523e-16 -4.1910919179599659e-15 
		-8.8817841970012523e-16 ;
	setAttr ".tg[0].tor" -type "double3" 7.9513867036587919e-16 -7.9513867036587919e-16 
		1.3914926731402886e-15 ;
	setAttr ".lr" -type "double3" -7.9513867036587919e-16 0 0 ;
	setAttr ".rst" -type "double3" 5.9150496043338237 -0.31537836291748444 -0.10238684840188483 ;
	setAttr ".rsrr" -type "double3" -7.9513867036587919e-16 0 0 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_heel_parentConstraint1" -p "j_l_heel";
	rename -uid "537C7C59-440F-AD98-2271-55B737BB2639";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_heelW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.7763568394002505e-15 3.3306690738754696e-15 
		-8.8817841970012523e-16 ;
	setAttr ".rst" -type "double3" -3.3872198826893332 -2.8224589625693843 0.23631473678988613 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_knee_parentConstraint1" -p "j_l_knee";
	rename -uid "E486E4CD-4269-2B40-6E86-E2BEB9A63453";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_kneeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.7763568394002505e-15 -3.5527136788005009e-15 
		-1.7763568394002505e-15 ;
	setAttr ".tg[0].tor" -type "double3" -1.366644589691355e-16 0 1.1220462682409134e-16 ;
	setAttr ".rst" -type "double3" 7.165529819711157 1.6191676710362191 -0.11219989622897319 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_l_femur_parentConstraint1" -p "j_l_femur";
	rename -uid "50A7C2F6-4F2D-5BD6-1DA7-BD8CAF8BC2AE";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_l_femurW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 0 -8.8817841970012523e-16 -1.7763568394002505e-15 ;
	setAttr ".tg[0].tor" -type "double3" 6.6791648310733855e-14 2.1071174764695797e-14 
		-1.2921003393445538e-15 ;
	setAttr ".lr" -type "double3" -5.7472559451374545 -0.73379799275174284 -0.045814184847084022 ;
	setAttr ".rst" -type "double3" -2.8585337946041669 0.19339463594915696 5.9043495013670508 ;
	setAttr ".rsrr" -type "double3" -5.7472559451374465 -0.73379799275177071 -0.045814184847065197 ;
	setAttr -k on ".w0";
createNode joint -n "j_r_femur" -p "j_pelvis";
	rename -uid "B7F25DFC-4149-35A6-B70E-D98034591C78";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 178.84688408448937 -4.2819196622724878 4.6088934566509998 ;
createNode joint -n "j_r_knee" -p "j_r_femur";
	rename -uid "60FAC696-414A-81C3-55FB-5086089B7316";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225630549339 178.04591234014006 17.576356065281974 ;
createNode joint -n "j_r_heel" -p "j_r_knee";
	rename -uid "3D55C380-4F7E-8207-8D12-9382164F7153";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.9090959104164237e-06 0 -180 ;
createNode joint -n "j_r_foot" -p "j_r_heel";
	rename -uid "F4467870-4D60-E9F3-6368-0CB578F6BCB4";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299386489367 5.4430139439201444 -23.175135311877707 ;
createNode joint -n "j_r_toe" -p "j_r_foot";
	rename -uid "06D60491-46E5-77F8-146B-EE8EC658783D";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222923039 -89.999999999997286 0 ;
createNode parentConstraint -n "j_r_toe_parentConstraint1" -p "j_r_toe";
	rename -uid "6B4A22A5-4B0B-34BF-757B-F0B2E1145BE9";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_toeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 6.2172489379008766e-15 1.5765166949677223e-14 
		7.1123662515049091e-15 ;
	setAttr ".tg[0].tor" -type "double3" 3.1805546814128183e-15 -5.7113796228072943e-15 
		-2.8006883316954101e-15 ;
	setAttr ".lr" -type "double3" 6.3611093629270351e-15 1.1927080055488187e-14 9.5416640443905503e-15 ;
	setAttr ".rst" -type "double3" -5.1907954725309597 -0.7779182942020948 7.0395245188592526e-11 ;
	setAttr ".rsrr" -type "double3" 6.3611093629270351e-15 1.1927080055488187e-14 9.5416640443905503e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_foot_parentConstraint1" -p "j_r_foot";
	rename -uid "39B7854D-47B3-9558-B93B-1481846052D4";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_footW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 8.8817841970012523e-16 8.2711615334574162e-15 
		-1.7763568394002505e-15 ;
	setAttr ".tg[0].tor" -type "double3" 7.9513867036587939e-16 2.3854160110976376e-15 
		9.7901448788798878e-15 ;
	setAttr ".lr" -type "double3" -7.9513867036587899e-16 -3.1805546814635168e-15 -6.3611093629270335e-15 ;
	setAttr ".rst" -type "double3" -5.915084487819886 0.31537365700333986 0.10238840764892565 ;
	setAttr ".rsrr" -type "double3" -7.9513867036587899e-16 -2.3854160110976376e-15 
		-6.3611093629270335e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_heel_parentConstraint1" -p "j_r_heel";
	rename -uid "D2B740BC-4FA5-1C21-20B1-C295AF0FCCF8";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_heelW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -3.5527136788005009e-15 -4.8849813083506888e-15 
		2.6645352591003757e-15 ;
	setAttr ".tg[0].tor" -type "double3" 0 4.2094290714742266e-38 1.4124500153760508e-30 ;
	setAttr ".rst" -type "double3" 3.3871896155177179 2.8224545928605567 -0.23631908512468414 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_knee_parentConstraint1" -p "j_r_knee";
	rename -uid "80CF3A64-4032-A06D-A24A-17847765D779";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_kneeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 3.5527136788005009e-15 3.9968028886505635e-15 
		3.5527136788005009e-15 ;
	setAttr ".tg[0].tor" -type "double3" -1.4908850069360235e-16 3.975693351829396e-16 
		-3.818063322450223e-15 ;
	setAttr ".lr" -type "double3" 0 -6.2120208622334312e-18 0 ;
	setAttr ".rst" -type "double3" -7.1655101418040488 -1.6191619138864928 0.11219730317127397 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_r_femur_parentConstraint1" -p "j_r_femur";
	rename -uid "DC6348FC-4780-E911-8D57-F087E347CB21";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_r_femurW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -3.5527136788005009e-15 8.8817841970012523e-16 
		1.7763568394002505e-15 ;
	setAttr ".tg[0].tor" -type "double3" -3.89617948479281e-14 9.5416640443905487e-15 
		-2.6338968455869743e-15 ;
	setAttr ".lr" -type "double3" -5.7472559451374226 -0.73379799275175883 -0.045814184847071504 ;
	setAttr ".rst" -type "double3" -2.8585509236681936 0.19338516215506996 -5.9038681567436413 ;
	setAttr ".rsrr" -type "double3" -5.7472559451373506 -0.73379799275176683 -0.045814184847077916 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "j_pelvis_parentConstraint1" -p "j_pelvis";
	rename -uid "67960D18-4682-8A7E-ACB4-7EBCEDCC9F49";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_pelvis_lowW0" -dv 1 -min 0 
		-at "double";
	addAttr -dcb 0 -ci true -k true -sn "w1" -ln "ctrl_j_pelvisW1" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr -s 2 ".tg";
	setAttr ".tg[0].tot" -type "double3" 2.3856583375447826e-11 1.8475928415234016e-11 
		3.2028495411395852e-09 ;
	setAttr ".tg[0].tor" -type "double3" -89.999937528620706 -79.522222998280384 3.83856789640961e-07 ;
	setAttr ".tg[1].tot" -type "double3" 3.1559039825879154e-09 -5.4687943062958766e-10 
		1.8476181983017106e-11 ;
	setAttr ".tg[1].tor" -type "double3" 1.9090355380911699e-05 -7.3297878020551805e-08 
		0.21998743728857481 ;
	setAttr ".lr" -type "double3" -1.8872809825589059e-07 7.15519165526284e-08 -5.7454774857591575e-14 ;
	setAttr ".rst" -type "double3" 23.828445236013525 4.4408920985006262e-16 7.5788442362167974e-16 ;
	setAttr ".rsrr" -type "double3" -1.8872808712396131e-07 7.1551919733076088e-08 -4.7913165243752541e-14 ;
	setAttr -k on ".w0";
	setAttr -k on ".w1";
createNode transform -s -n "side";
	rename -uid "88401422-464F-FC33-9BEA-9EB8D9D85CC9";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 1000.1 4.3500522792260599 21.898142563009969 ;
	setAttr ".r" -type "double3" 90 1.2722218725854067e-14 89.999999999999986 ;
	setAttr ".rp" -type "double3" 2.7748696160486913e-17 -5.0653918619067625e-14 0 ;
	setAttr ".rpt" -type "double3" -2.774869616047566e-17 -2.0178310193791633 -10.233497242806379 ;
createNode camera -s -n "sideShape" -p "side";
	rename -uid "75F48913-4F11-5E8A-21D1-CCAE720212B6";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 1000.1;
	setAttr ".ow" 39.646433560422899;
	setAttr ".imn" -type "string" "side";
	setAttr ".den" -type "string" "side_depth";
	setAttr ".man" -type "string" "side_mask";
	setAttr ".hc" -type "string" "viewSet -s %camera";
	setAttr ".o" yes;
createNode transform -n "prnt_root";
	rename -uid "AE0FA0BB-4342-8A22-F4CD-4E80B049DDB2";
	setAttr ".t" -type "double3" 0 6.6613381477509392e-16 -2.2204460492503131e-16 ;
	setAttr ".r" -type "double3" -89.982224209999927 -88.122645779999999 -0.017766250060206584 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 2.2204460492503131e-16 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 2.2204460492503131e-16 ;
createNode transform -n "offset_root" -p "prnt_root";
	rename -uid "E108842F-4A7B-85A7-9DB5-36862C7DABE8";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 2.2204460492503131e-16 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 2.2204460492503131e-16 ;
createNode transform -n "ctrl_root" -p "offset_root";
	rename -uid "6602A572-499B-B7AD-6C99-E9A9F570AE8B";
createNode nurbsCurve -n "ctrl_rootShape" -p "ctrl_root";
	rename -uid "42CAAFE6-4BA7-2DB8-6211-D682557CFB75";
	setAttr -k off ".v";
	setAttr ".tw" yes;
createNode nurbsCurve -n "ctrl_rootShape1" -p "ctrl_root";
	rename -uid "A2C53377-4EF4-E9D6-16EA-EAB7EF66AF45";
	setAttr -k off ".v";
	setAttr ".tw" yes;
createNode nurbsCurve -n "ctrl_rootShape2" -p "ctrl_root";
	rename -uid "F774AAC1-4D4E-71A3-A01A-CB82EC95E6AE";
	setAttr -k off ".v";
	setAttr ".tw" yes;
createNode transform -n "prnt_world" -p "ctrl_root";
	rename -uid "D1119008-47A7-3D4D-E628-5FA0150426CB";
	setAttr ".t" -type "double3" 3.4916227893001004e-16 9.9862863822880168e-15 2.2204460517666512e-16 ;
	setAttr ".r" -type "double3" 0 -0.00058233753183872642 -1.8773541297145149 ;
	setAttr ".s" -type "double3" 0.99999999999999989 0.99999999999999989 0.99999999999999978 ;
	setAttr ".rp" -type "double3" 0 -1.0658141036401501e-14 0 ;
	setAttr ".rpt" -type "double3" -3.4916227893001123e-16 5.7208393383887391e-18 -1.5046327690525283e-36 ;
	setAttr ".sp" -type "double3" 0 -1.0658141036401503e-14 0 ;
	setAttr ".spt" -type "double3" 0 3.1554436208840469e-30 0 ;
createNode transform -n "offset_world" -p "prnt_world";
	rename -uid "D1DD51F4-42FB-0E99-2231-EC95C9A6337A";
	setAttr ".rp" -type "double3" 0 -1.0658141036401503e-14 0 ;
	setAttr ".sp" -type "double3" 0 -1.0658141036401503e-14 0 ;
createNode transform -n "ctrl_world" -p "offset_world";
	rename -uid "F8978558-44C9-DAA4-F6EE-3DAB2E5CC08B";
createNode nurbsCurve -n "ctrl_worldShape" -p "ctrl_world";
	rename -uid "D5EAA836-4080-B746-CB82-C091E05C84C9";
	setAttr -k off ".v";
	setAttr ".tw" yes;
createNode transform -n "prnt_cog" -p "ctrl_world";
	rename -uid "D39AB784-4237-A818-59E1-2088D2B4C45D";
	setAttr ".rp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
	setAttr ".rpt" -type "double3" 23.035031378269203 0.78086543173412259 -23.81589681000332 ;
	setAttr ".sp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
createNode transform -n "offset_cog" -p "prnt_cog";
	rename -uid "C41695F8-4B4F-1D2F-A11D-D18FE1F566C3";
	setAttr ".rp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
	setAttr ".sp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
createNode parentConstraint -n "prnt_cog_parentConstraint1" -p "prnt_cog";
	rename -uid "ECF54CC6-45DF-E293-5480-10BFFE5ADB70";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_rootW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 23.815654754638672 0.78062337636946033 -0.00024205536465177882 ;
	setAttr ".tg[0].tor" -type "double3" 90 1.2722218725854067e-14 89.999999999999986 ;
	setAttr ".lr" -type "double3" 89.999999999999986 0 89.999999999999986 ;
	setAttr ".rsrr" -type "double3" -1.2722218725854067e-14 1.4124500153760508e-30 1.2722218725854067e-14 ;
	setAttr -k on ".w0";
createNode transform -n "ctrl_cog" -p "prnt_cog";
	rename -uid "32CCAB3D-4C82-809B-E5F9-FD8531856723";
	setAttr ".t" -type "double3" 0 0 -3.941151930913548e-46 ;
	setAttr ".rp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
	setAttr ".sp" -type "double3" 0.78062337636947632 -0.00024205536465160549 23.815654754638672 ;
createNode nurbsCurve -n "ctrl_cogShape" -p "ctrl_cog";
	rename -uid "46114575-4037-8042-7005-FDAB7CEAF9B1";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		18.077997434635961 -17.578542031251043 26.406818764691756
		25.242777546423206 -0.00021479171152962427 26.406818764691753
		18.077959520640892 17.578096477149071 26.406818764691756
		0.78059658485700112 24.859255437648066 26.406818764691774
		-16.516750646435948 17.578057920519445 26.406818764691792
		-23.681530758223211 -0.00026931902006940649 26.406818764691796
		-16.516712732440883 -17.578580587880669 26.406818764691792
		0.78065020334300461 -24.859739548379665 26.406818764691774
		18.077997434635961 -17.578542031251043 26.406818764691756
		25.242777546423206 -0.00021479171152962427 26.406818764691753
		18.077959520640892 17.578096477149071 26.406818764691756
		;
createNode transform -n "prnt_pelvis" -p "ctrl_cog";
	rename -uid "0D67F02C-4A90-4260-0089-F79AA296D893";
	setAttr ".t" -type "double3" 0.78062339410000003 -0.00024205536579467092 23.81565513 ;
	setAttr ".r" -type "double3" -89.99993582999997 -79.742191340000019 -1.3548124482568519e-06 ;
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "offset_pelvis" -p "prnt_pelvis";
	rename -uid "3AC2617A-4A04-BAF4-F3BB-2C9BED4543AD";
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "ctrl_pelvis" -p "offset_pelvis";
	rename -uid "9ACC928D-4D98-DF13-9BB0-B5B82A2980A5";
	setAttr ".t" -type "double3" 3.5527136788005009e-15 8.8817841970012523e-16 0 ;
	setAttr ".s" -type "double3" 1 1 0.99999999999999989 ;
createNode mesh -n "ctrl_pelvisShape" -p "ctrl_pelvis";
	rename -uid "66ACD939-4A34-668A-6625-D99D51BF2D64";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:20]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 36 ".uvst[0].uvsp[0:35]" -type "float2" 0.375 0 0.45833334
		 0 0.45833334 0.083333336 0.375 0.083333336 0.54166669 0 0.54166669 0.083333336 0.625
		 0 0.625 0.083333336 0.45833334 0.16666667 0.375 0.16666667 0.54166669 0.16666667
		 0.625 0.16666667 0.45833334 0.25 0.375 0.25 0.54166669 0.25 0.625 0.25 0.54166669
		 0.87628084 0.625 0.87628084 0.625 0.99999994 0.54166669 0.99999994 0.45833334 0.87628084
		 0.45833334 0.99999994 0.375 0.87628084 0.375 0.99999994 0.2512809 0.083333336 0.2512809
		 0 0.2512809 0.16666667 0.25128093 0.25 0.45833334 0.3737191 0.375 0.3737191 0.54166669
		 0.3737191 0.625 0.3737191 0.7487191 0.16666667 0.7487191 0.25 0.7487191 0.083333336
		 0.7487191 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 28 ".vt[0:27]"  5.52364826 -7.59008265 -8.74403 5.96895981 -3.54146099 -11.56559753
		 6.63305426 2.49628067 -11.56560516 7.079726219 6.55728245 -8.57250786 5.30486584 -9.57919216 -3.85519028
		 5.96895981 -3.54145217 -3.85519791 6.63305426 2.49628901 -3.85520172 7.29715014 8.53402996 -3.85521126
		 5.30486584 -9.57918358 3.85521126 5.96895981 -3.54144382 3.85520554 6.63305426 2.4962976 3.85519791
		 7.29715061 8.53403854 3.85519218 5.52364826 -7.59006405 8.74404716 5.96895981 -3.54143524 11.56560516
		 6.63305378 2.49630737 11.56559753 7.079726219 6.55730152 8.5724926 2.93192673 7.87338734 -9.1386013
		 2.43165278 3.32505226 -12.49087906 1.68786454 -3.43723869 -12.49087143 1.18911362 -7.97170925 -9.33070946
		 0.94407654 -10.19951916 -3.85518837 0.94407654 -10.19951057 3.85521317 1.18911552 -7.97168827 9.33072662
		 1.68786454 -3.43721104 12.49088001 2.43165278 3.32507992 12.49087238 2.93192673 7.87340832 9.13858223
		 3.17544079 10.087360382 3.85519028 3.17544079 10.087352753 -3.85521126;
	setAttr -s 48 ".ed[0:47]"  0 1 0 1 2 0 2 3 0 4 5 1 5 6 1 6 7 1 8 9 1
		 9 10 1 10 11 1 12 13 0 13 14 0 14 15 0 0 4 0 1 5 1 2 6 1 3 7 0 4 8 0 5 9 1 6 10 1
		 7 11 0 8 12 0 9 13 1 10 14 1 11 15 0 12 22 0 13 23 1 14 24 1 15 25 0 16 3 0 17 2 1
		 16 17 0 18 1 1 17 18 0 19 0 0 18 19 0 20 4 1 19 20 0 21 8 1 20 21 0 21 22 0 22 23 0
		 23 24 0 24 25 0 26 11 1 25 26 0 27 7 1 26 27 0 27 16 0;
	setAttr -s 21 -ch 84 ".fc[0:20]" -type "polyFaces" 
		f 4 0 13 -4 -13
		mu 0 4 0 1 2 3
		f 4 1 14 -5 -14
		mu 0 4 1 4 5 2
		f 4 2 15 -6 -15
		mu 0 4 4 6 7 5
		f 4 3 17 -7 -17
		mu 0 4 3 2 8 9
		f 4 4 18 -8 -18
		mu 0 4 2 5 10 8
		f 4 5 19 -9 -19
		mu 0 4 5 7 11 10
		f 4 6 21 -10 -21
		mu 0 4 9 8 12 13
		f 4 7 22 -11 -22
		mu 0 4 8 10 14 12
		f 4 8 23 -12 -23
		mu 0 4 10 11 15 14
		f 4 -31 28 -3 -30
		mu 0 4 16 17 18 19
		f 4 -33 29 -2 -32
		mu 0 4 20 16 19 21
		f 4 -35 31 -1 -34
		mu 0 4 22 20 21 23
		f 4 -37 33 12 -36
		mu 0 4 24 25 0 3
		f 4 -39 35 16 -38
		mu 0 4 26 24 3 9
		f 4 -40 37 20 24
		mu 0 4 27 26 9 13
		f 4 9 25 -41 -25
		mu 0 4 13 12 28 29
		f 4 10 26 -42 -26
		mu 0 4 12 14 30 28
		f 4 11 27 -43 -27
		mu 0 4 14 15 31 30
		f 4 -44 -45 -28 -24
		mu 0 4 11 32 33 15
		f 4 -46 -47 43 -20
		mu 0 4 7 34 32 11
		f 4 -29 -48 45 -16
		mu 0 4 6 35 34 7;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_spine_01" -p "ctrl_pelvis";
	rename -uid "4E1250EC-4868-2739-E1E1-29B9BF661FBB";
	setAttr ".t" -type "double3" 8.5648696006317309 0.032882166021422687 2.870652852796432e-12 ;
	setAttr ".r" -type "double3" -9.4787915988670522e-23 -9.0890939468909133e-06 -8.0967291599949114 ;
	setAttr ".s" -type "double3" 0.99999999999999978 0.99999999999999989 1 ;
	setAttr ".rp" -type "double3" 0 -5.3290705182007498e-15 0 ;
	setAttr ".rpt" -type "double3" -7.5057141461709227e-16 5.3121775129404856e-17 -3.2326094647612906e-38 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".spt" -type "double3" 0 1.5777218104420234e-30 0 ;
createNode transform -n "offset_spine_01" -p "prnt_spine_01";
	rename -uid "A71702B1-49D4-D3DD-BCBC-8E890C2FABD1";
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "ctrl_spine_01" -p "offset_spine_01";
	rename -uid "6D37FAD4-4F68-7BCB-7914-3491A1CE09C1";
	setAttr ".rp" -type "double3" 1.877741695466284e-06 3.0297746755891808e-08 1.1151080059335072e-12 ;
	setAttr ".sp" -type "double3" 1.877741695466284e-06 3.0297746755891808e-08 1.1151080059335072e-12 ;
createNode mesh -n "ctrl_spine_0Shape1" -p "ctrl_spine_01";
	rename -uid "E4BC0E76-4790-9F2A-4577-DC8B8B9DAC72";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 32 ".uvst[0].uvsp[0:31]" -type "float2" 0.71265912 0.083333336
		 0.71265912 0 0.74333996 0 0.74333996 0.083333343 0.54166669 0.88165998 0.625 0.88165998
		 0.625 0.91234082 0.54166669 0.91234082 0.45833334 0.88165998 0.45833334 0.91234082
		 0.375 0.88165998 0.375 0.91234082 0.25666007 0.083333343 0.25666007 0 0.28734091
		 0 0.28734091 0.083333336 0.25666007 0.16666669 0.28734091 0.16666667 0.2566601 0.25
		 0.28734094 0.25 0.375 0.33765906 0.45833331 0.33765906 0.45833331 0.36833993 0.375
		 0.36833993 0.54166663 0.33765906 0.54166669 0.36833993 0.625 0.33765906 0.625 0.36833993
		 0.71265912 0.25 0.71265912 0.16666667 0.74333996 0.16666669 0.74333996 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 24 ".pt[0:23]" -type "float3"  6.1678004 5.1969161 6.7803302 
		6.4728379 1.5708152 9.2549019 6.9263568 -3.6612878 9.2549076 7.2304654 -7.0688462 
		6.9221649 7.3798747 -8.617815 2.8802865 7.3798747 -8.3354788 -3.6506526 7.2304645 
		-6.4370441 -7.6925354 6.9263558 -2.8277943 -10.025284 6.4728374 2.4043086 -10.02529 
		6.1677995 5.8164558 -7.5507274 6.0193181 7.3608384 -3.6506698 6.0193181 7.0785022 
		2.8802693 -1.4678123 8.2901869 -3.3938551 -1.2966872 6.5134916 -7.9628658 -0.94512975 
		2.5830092 -10.861876 -0.42244732 -3.4470143 -10.86187 -0.071961001 -7.6086082 -8.1289997 
		0.10023521 -9.7998857 -3.3938355 0.10023521 -10.132622 4.302928 -0.071960218 -8.3507509 
		9.0380869 -0.42244652 -4.4254441 11.770949 -0.94512898 1.6045798 11.770943 -1.2966864 
		5.7857137 8.8719225 -1.4678123 7.9574509 4.3029084;
	setAttr -s 24 ".vt[0:23]"  0.35534841 0.30977762 0.3851926 0.16213079 0.41675726 0.3851926
		 -0.12513798 0.41675726 0.3851926 -0.31776702 0.31590879 0.3851926 -0.41240692 0.14117163 0.38519251
		 -0.41240692 -0.14117162 0.38519251 -0.31776702 -0.31590879 0.38519251 -0.12513798 -0.4167572 0.38519251
		 0.16213079 -0.4167572 0.38519251 0.35534841 -0.30977762 0.38519251 0.44939986 -0.14117162 0.38519251
		 0.44939986 0.14117163 0.38519251 0.51193202 -0.16637187 -0.45453513 0.40353763 -0.36389783 -0.45453513
		 0.18085335 -0.489227 -0.45453513 -0.15022528 -0.489227 -0.45453513 -0.37223107 -0.37108073 -0.45453513
		 -0.48130396 -0.16637187 -0.45453513 -0.48130396 0.1663719 -0.45453513 -0.37223107 0.37108073 -0.45453504
		 -0.15022528 0.48922706 -0.45453504 0.18085335 0.48922706 -0.45453504 0.4035376 0.36389783 -0.45453504
		 0.51193202 0.1663719 -0.45453513;
	setAttr -s 36 ".ed[0:35]"  0 22 0 1 21 1 0 1 0 2 20 1 1 2 0 3 19 0 2 3 0
		 3 4 0 4 5 0 5 6 0 6 7 0 7 8 0 8 9 0 9 10 0 10 11 0 11 0 0 12 10 1 13 9 0 12 13 0
		 14 8 1 13 14 0 15 7 1 14 15 0 16 6 0 15 16 0 17 5 1 16 17 0 18 4 1 17 18 0 18 19 0
		 19 20 0 20 21 0 21 22 0 23 11 1 22 23 0 23 12 0;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 -14 -18 -19 16
		mu 0 4 0 1 2 3
		f 4 -21 17 -13 -20
		mu 0 4 4 5 6 7
		f 4 -23 19 -12 -22
		mu 0 4 8 4 7 9
		f 4 -25 21 -11 -24
		mu 0 4 10 8 9 11
		f 4 -27 23 -10 -26
		mu 0 4 12 13 14 15
		f 4 -29 25 -9 -28
		mu 0 4 16 12 15 17
		f 4 -30 27 -8 5
		mu 0 4 18 16 17 19
		f 4 -7 3 -31 -6
		mu 0 4 20 21 22 23
		f 4 -5 1 -32 -4
		mu 0 4 21 24 25 22
		f 4 -3 0 -33 -2
		mu 0 4 24 26 27 25
		f 4 -16 -34 -35 -1
		mu 0 4 28 29 30 31
		f 4 -15 -17 -36 33
		mu 0 4 29 0 3 30;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_spine_02" -p "ctrl_spine_01";
	rename -uid "5AD323D3-4185-9AF7-8407-69981FAF3C9E";
	setAttr ".t" -type "double3" 11.089088717430492 4.9292991910476758e-10 8.0637536578609392e-17 ;
	setAttr ".r" -type "double3" -6.1405203224196951e-05 -9.7853674787233648e-06 -9.0543685699947396 ;
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".rpt" -type "double3" -8.3864447313540896e-16 6.6403130306733977e-17 5.7112873050520148e-21 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "offset_spine_02" -p "prnt_spine_02";
	rename -uid "9EBE3FE3-4217-CB40-C6A8-C19F00B0E6E2";
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "ctrl_spine_02" -p "offset_spine_02";
	rename -uid "C78AFC7D-494B-8743-1D71-28A1E7DCCCAA";
	setAttr ".rp" -type "double3" -2.2595331472530233e-07 4.6489956773143604e-08 1.1484146966722619e-12 ;
	setAttr ".sp" -type "double3" -2.2595331472530233e-07 4.6489956773143604e-08 1.1484146966722619e-12 ;
createNode mesh -n "ctrl_spine_0Shape2" -p "ctrl_spine_02";
	rename -uid "B5A9C707-4A3A-CD79-D173-A19233A0D5C8";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 32 ".uvst[0].uvsp[0:31]" -type "float2" 0.67491138 0.083333336
		 0.67491138 0 0.70776665 0 0.70776665 0.083333336 0.54166669 0.91723323 0.625 0.91723323
		 0.625 0.9500885 0.54166669 0.9500885 0.45833334 0.91723323 0.45833334 0.9500885 0.375
		 0.91723323 0.375 0.9500885 0.29223335 0.083333336 0.29223335 0 0.32508859 0 0.32508859
		 0.083333336 0.29223335 0.16666667 0.32508859 0.16666667 0.29223338 0.25 0.32508859
		 0.25 0.375 0.29991138 0.45833331 0.29991138 0.45833331 0.33276659 0.375 0.33276659
		 0.54166663 0.29991138 0.54166663 0.33276659 0.625 0.29991138 0.625 0.33276659 0.67491138
		 0.25 0.67491138 0.16666667 0.70776665 0.16666667 0.70776665 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 24 ".pt[0:23]" -type "float3"  3.5404687 4.6928768 5.0321026 
		4.3337264 1.3974209 7.267808 5.5131125 -3.3584416 7.267808 6.3039541 -6.456389 5.1602321 
		6.6924992 -7.8653255 1.5084991 6.6924992 -7.6124811 -4.3400965 6.3039536 -5.8878045 
		-7.9918294 5.5131116 -2.6076286 -10.099404 4.333725 2.1482341 -10.099404 3.5404677 
		5.2503834 -7.8637009 3.1543362 6.6551228 -4.3400965 3.1543362 6.4022784 1.5084991 
		-5.0392599 6.5692997 -3.7284472 -4.626091 5.0696349 -7.5782566 -3.7772853 1.7524358 
		-10.020939 -2.5153124 -3.3364568 -10.020939 -1.6690923 -6.8483796 -7.7182498 -1.2533389 
		-8.6973867 -3.7284472 -1.2533389 -8.9758015 2.7116334 -1.6690912 -7.4717665 6.7014351 
		-2.5153115 -4.1589413 9.0041256 -3.7772844 0.92995119 9.0041256 -4.62609 4.4583526 
		6.5614419 -5.0392599 6.290884 2.7116334;
	setAttr -s 24 ".vt[0:23]"  0.27379286 0.2787534 1.41579878 0.09504132 0.37540662 1.41579878
		 -0.17071992 0.37540662 1.41579878 -0.34892711 0.28429264 1.41579878 -0.43648148 0.12642221 1.41579866
		 -0.43648148 -0.12642221 1.41579866 -0.34892714 -0.28429264 1.41579866 -0.17071992 -0.37540659 1.41579866
		 0.095041335 -0.37540659 1.41579866 0.27379286 -0.27875343 1.41579866 0.36080316 -0.12642221 1.41579866
		 0.36080316 0.12642221 1.41579866 0.43950173 -0.13920763 0.50840718 0.34639889 -0.30564123 0.50840718
		 0.15513019 -0.4112424 0.50840718 -0.12924102 -0.4112424 0.50840718 -0.3199271 -0.31169337 0.50840718
		 -0.41361237 -0.13920763 0.50840718 -0.41361237 0.13920766 0.50840718 -0.3199271 0.31169337 0.50840729
		 -0.12924102 0.41124246 0.50840729 0.15513019 0.41124246 0.50840729 0.34639889 0.30564123 0.50840729
		 0.43950173 0.13920766 0.50840718;
	setAttr -s 36 ".ed[0:35]"  0 22 0 1 21 1 0 1 0 2 20 1 1 2 0 3 19 0 2 3 0
		 3 4 0 4 5 0 5 6 0 6 7 0 7 8 0 8 9 0 9 10 0 10 11 0 11 0 0 12 10 1 13 9 0 12 13 0
		 14 8 1 13 14 0 15 7 1 14 15 0 16 6 0 15 16 0 17 5 1 16 17 0 18 4 1 17 18 0 18 19 0
		 19 20 0 20 21 0 21 22 0 23 11 1 22 23 0 23 12 0;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 -14 -18 -19 16
		mu 0 4 0 1 2 3
		f 4 -21 17 -13 -20
		mu 0 4 4 5 6 7
		f 4 -23 19 -12 -22
		mu 0 4 8 4 7 9
		f 4 -25 21 -11 -24
		mu 0 4 10 8 9 11
		f 4 -27 23 -10 -26
		mu 0 4 12 13 14 15
		f 4 -29 25 -9 -28
		mu 0 4 16 12 15 17
		f 4 -30 27 -8 5
		mu 0 4 18 16 17 19
		f 4 -7 3 -31 -6
		mu 0 4 20 21 22 23
		f 4 -5 1 -32 -4
		mu 0 4 21 24 25 22
		f 4 -3 0 -33 -2
		mu 0 4 24 26 27 25
		f 4 -16 -34 -35 -1
		mu 0 4 28 29 30 31
		f 4 -15 -17 -36 33
		mu 0 4 29 0 3 30;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_spine_03" -p "ctrl_spine_02";
	rename -uid "9C28139A-4038-90E8-F833-7A9845096787";
	setAttr ".t" -type "double3" 11.32431581574847 8.7967588768833593e-10 -1.0931914404201278e-10 ;
	setAttr ".r" -type "double3" -9.2288537362030301e-05 -0.0020204216667995133 5.231156637627028 ;
	setAttr ".s" -type "double3" 1 1 0.99999999999999989 ;
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".rpt" -type "double3" 4.8587328623724091e-16 2.2195756384361207e-17 8.5837408531212537e-21 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "offset_spine_03" -p "prnt_spine_03";
	rename -uid "85C1C35E-442C-B08F-EEFD-D29E26D4A4BA";
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "ctrl_spine_03" -p "offset_spine_03";
	rename -uid "98D85747-4791-7576-9BF6-D3B5AA3CD6EB";
	setAttr ".rp" -type "double3" 1.1838626079452297e-06 4.8305568434159341e-08 -4.0511594079362112e-11 ;
	setAttr ".sp" -type "double3" 1.1838626079452297e-06 4.8305568434159341e-08 -4.0511594079362112e-11 ;
createNode mesh -n "ctrl_spine_0Shape3" -p "ctrl_spine_03";
	rename -uid "89480C5D-4054-B745-C1B1-4F88C4AEBB50";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:32]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 52 ".uvst[0].uvsp[0:51]" -type "float2" 0.375 0 0.45833334
		 0 0.45833334 0.083333336 0.375 0.083333336 0.54166669 0 0.54166669 0.083333336 0.625
		 0 0.625 0.083333336 0.45833334 0.16666667 0.375 0.16666667 0.54166669 0.16666667
		 0.625 0.16666667 0.45833334 0.25 0.375 0.25 0.54166669 0.25 0.625 0.25 0.64762104
		 0.16666667 0.64762104 0.083333336 0.67039204 0.083333336 0.67039204 0.16666667 0.64762104
		 0 0.67039204 0 0.54166669 0.95460784 0.625 0.95460784 0.625 0.97737885 0.54166669
		 0.97737885 0.45833334 0.95460784 0.45833334 0.97737885 0.375 0.95460784 0.375 0.97737885
		 0.3296079 0.083333336 0.3296079 0 0.35237896 0 0.35237896 0.083333336 0.3296079 0.16666667
		 0.35237896 0.16666667 0.3296079 0.25 0.35237896 0.25 0.375 0.27262101 0.45833331
		 0.27262101 0.45833331 0.29539204 0.375 0.29539204 0.54166663 0.27262101 0.54166663
		 0.29539204 0.625 0.27262101 0.625 0.29539204 0.67039204 0.25 0.64762104 0.25 0.625
		 0.99999994 0.54166669 0.99999994 0.45833334 0.99999994 0.375 0.99999994;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 40 ".pt[0:39]" -type "float3"  4.928637 -5.7114482 -8.5735188 
		5.6801453 -2.51565 -10.171252 4.9679174 2.1105196 -10.171228 3.4410405 5.1292472 
		-8.5093231 5.7132897 -7.365634 -5.3093729 7.3048606 -2.6820555 -5.5694633 6.5926328 
		1.9441148 -5.5694399 3.9773064 6.5228877 -5.3545446 5.7134771 -7.5954003 0.0051970575 
		7.305048 -2.9118216 -0.25489333 6.5928202 1.7143487 -0.25486985 3.9774938 6.2931218 
		-0.03997438 4.9290566 -6.2288227 3.3935311 5.6806698 -3.1591768 4.7137394 4.9684424 
		1.4669931 4.7137628 3.4414563 4.6191883 3.2885151 -6.5162163 7.021399 1.3524463 -6.5164194 
		7.2706127 -4.4119506 -6.2760749 5.858264 -7.8715024 -5.7821531 2.7450311 -10.080996 
		-5.0476809 -2.0250165 -10.095194 -4.5550952 -5.3141236 -8.0106478 -4.3129983 -7.0413852 
		-4.4120235 -4.3127952 -7.2905989 1.3523734 -4.5546374 -5.8744969 4.9510131 -5.0470715 
		-2.7656357 7.035593 -5.7815452 2.0056372 7.0214434 -6.2756267 5.3099155 4.8119812 
		-1.7068819 8.2977285 -5.1281819 -1.4277617 6.6386595 -8.7072506 -0.83830893 2.9177608 
		-11.214117 0.0304661 -2.7026629 -11.737846 0.60671544 -6.5784574 -8.6498814 0.89677459 
		-8.6172628 -5.0509577 0.89698356 -8.8734207 0.87404716 0.60717809 -7.1458011 4.47299 
		0.03114249 -3.5370154 7.5609951 -0.8376652 2.128691 7.0373168 -1.4272949 6.0663486 
		4.5304937 -1.7066678 8.0348892 0.95144367;
	setAttr -s 40 ".vt[0:39]"  -0.42224476 -0.25867763 2.58982515 -0.25611457 -0.32175136 2.72856069
		 -0.0010063455 -0.32175136 2.72856069 0.17478602 -0.25501999 2.61028433 -0.50849688 -0.11487881 2.65189242
		 -0.26263544 -0.11487881 2.91192555 -0.0075271875 -0.11487881 2.91192555 0.25522098 -0.11487881 2.69712043
		 -0.50849688 0.11487881 2.65189242 -0.26263544 0.11487881 2.91192555 -0.0075271875 0.11487881 2.91192555
		 0.25522098 0.11487881 2.69712043 -0.42224476 0.25867763 2.58982515 -0.25611457 0.32175136 2.72856069
		 -0.0010063455 0.32175136 2.72856069 0.17478602 0.25501999 2.61028433 0.3516306 0.12460219 1.52998114
		 0.3516306 -0.12460219 1.52998114 0.26549938 -0.27416396 1.52998114 0.08855392 -0.3696833 1.52998114
		 -0.17452218 -0.37029606 1.52998114 -0.3509289 -0.28017697 1.52998114 -0.43759862 -0.12460219 1.52998114
		 -0.43759862 0.12460219 1.52998114 -0.35092884 0.28017697 1.52998126 -0.17452218 0.37029609 1.52998126
		 0.088553905 0.36968333 1.52998126 0.26549938 0.27416393 1.52998126 0.3812376 -0.13141611 2.088428974
		 0.28121603 -0.28614476 2.088428974 0.070052087 -0.3945199 2.088428974 -0.24113247 -0.41716033 2.088428974
		 -0.44749948 -0.28366166 2.088428974 -0.55134845 -0.12807386 2.088428974 -0.55134845 0.12807386 2.088428974
		 -0.44749945 0.28366166 2.088428974 -0.24113247 0.41716039 2.088428974 0.07005205 0.39451993 2.088428974
		 0.28121603 0.28614473 2.088428974 0.3812376 0.13141611 2.088428974;
	setAttr -s 72 ".ed[0:71]"  0 1 0 1 2 0 2 3 0 4 5 1 5 6 1 6 7 1 8 9 1
		 9 10 1 10 11 1 12 13 0 13 14 0 14 15 0 0 4 0 1 5 1 2 6 1 3 7 0 4 8 0 5 9 1 6 10 1
		 7 11 0 8 12 0 9 13 1 10 14 1 11 15 0 12 35 0 13 36 1 14 37 1 15 38 0 16 39 1 17 28 1
		 16 17 0 18 29 0 17 18 0 19 30 1 18 19 0 20 31 1 19 20 0 21 32 0 20 21 0 22 33 1 21 22 0
		 23 34 1 22 23 0 23 24 0 24 25 0 25 26 0 26 27 0 27 16 0 28 7 1 29 3 0 28 29 1 30 2 1
		 29 30 1 31 1 1 30 31 1 32 0 0 31 32 1 33 4 1 32 33 1 34 8 1 33 34 1 35 24 0 34 35 1
		 36 25 1 35 36 1 37 26 1 36 37 1 38 27 0 37 38 1 39 11 1 38 39 1 39 28 1;
	setAttr -s 33 -ch 132 ".fc[0:32]" -type "polyFaces" 
		f 4 0 13 -4 -13
		mu 0 4 0 1 2 3
		f 4 1 14 -5 -14
		mu 0 4 1 4 5 2
		f 4 2 15 -6 -15
		mu 0 4 4 6 7 5
		f 4 3 17 -7 -17
		mu 0 4 3 2 8 9
		f 4 4 18 -8 -18
		mu 0 4 2 5 10 8
		f 4 5 19 -9 -19
		mu 0 4 5 7 11 10
		f 4 6 21 -10 -21
		mu 0 4 9 8 12 13
		f 4 7 22 -11 -22
		mu 0 4 8 10 14 12
		f 4 8 23 -12 -23
		mu 0 4 10 11 15 14
		f 4 71 -30 -31 28
		mu 0 4 16 17 18 19
		f 4 -32 -33 29 50
		mu 0 4 20 21 18 17
		f 4 -35 31 52 -34
		mu 0 4 22 23 24 25
		f 4 -37 33 54 -36
		mu 0 4 26 22 25 27
		f 4 -39 35 56 -38
		mu 0 4 28 26 27 29
		f 4 -41 37 58 -40
		mu 0 4 30 31 32 33
		f 4 -43 39 60 -42
		mu 0 4 34 30 33 35
		f 4 -44 41 62 61
		mu 0 4 36 34 35 37
		f 4 64 63 -45 -62
		mu 0 4 38 39 40 41
		f 4 66 65 -46 -64
		mu 0 4 39 42 43 40
		f 4 68 67 -47 -66
		mu 0 4 42 44 45 43
		f 4 -29 -48 -68 70
		mu 0 4 16 19 46 47
		f 4 -50 -51 48 -16
		mu 0 4 6 20 17 7
		f 4 -53 49 -3 -52
		mu 0 4 25 24 48 49
		f 4 -55 51 -2 -54
		mu 0 4 27 25 49 50
		f 4 -57 53 -1 -56
		mu 0 4 29 27 50 51
		f 4 -59 55 12 -58
		mu 0 4 33 32 0 3
		f 4 -61 57 16 -60
		mu 0 4 35 33 3 9
		f 4 -63 59 20 24
		mu 0 4 37 35 9 13
		f 4 9 25 -65 -25
		mu 0 4 13 12 39 38
		f 4 10 26 -67 -26
		mu 0 4 12 14 42 39
		f 4 11 27 -69 -27
		mu 0 4 14 15 44 42
		f 4 -70 -71 -28 -24
		mu 0 4 11 16 47 15
		f 4 -49 -72 69 -20
		mu 0 4 7 17 16 11;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_neck" -p "ctrl_spine_03";
	rename -uid "24EACF38-4042-E008-B9AC-09820740AF45";
	setAttr ".t" -type "double3" 6.8674732272625292 -0.00039489910461654176 -1.491765539494809e-07 ;
	setAttr ".r" -type "double3" 1.2132598730675856e-05 0.0020191699518100899 0.68705899605311971 ;
	setAttr ".s" -type "double3" 1 1 0.99999999999999989 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".rpt" -type "double3" 4.2601137717712196e-17 2.5542758898586852e-19 -7.5230060240757282e-22 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_neck" -p "prnt_neck";
	rename -uid "DA9D9306-45BE-E754-7111-1F8BD65F7495";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_neck" -p "offset_neck";
	rename -uid "8684056A-4D96-B870-6455-B38EE3DC4D60";
	setAttr ".rp" -type "double3" 1.3518690992896225 0.00043311666405765337 3.6887614779372573e-08 ;
	setAttr ".sp" -type "double3" 1.3518690992896225 0.00043311666405765337 3.6887614779372573e-08 ;
createNode mesh -n "ctrl_neckShape" -p "ctrl_neck";
	rename -uid "5D6182DB-4567-9BCE-A2FB-5B869C3A2FA6";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:15]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 26 ".uvst[0].uvsp[0:25]" -type "float2" 0 0.875 0.125 0.875
		 0.0625 1 0.25 0.875 0.1875 1 0.375 0.875 0.3125 1 0.5 0.875 0.4375 1 0.625 0.875
		 0.5625 1 0.75 0.875 0.6875 1 0.875 0.875 0.8125 1 1 0.875 0.9375 1 0.75 0.85991883
		 0.875 0.85991883 0.625 0.85991883 0.5 0.85991883 0.375 0.85991883 0.25 0.85991883
		 0.125 0.85991883 0 0.85991883 1 0.85991883;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 17 ".pt[0:16]" -type "float3"  1.3518691 0.00043311666 3.6887613e-08 
		1.3518691 0.00043311666 3.6887613e-08 1.3518691 0.00043311666 3.6887613e-08 1.3518691 
		0.00043311666 3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 1.3518691 0.00043311666 
		3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 
		1.3518691 0.00043311666 3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 1.3518691 
		0.00043311666 3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 1.3518691 0.00043311666 
		3.6887617e-08 1.3518691 0.00043311666 3.6887617e-08 1.3518691 0.00043311666 3.6887613e-08 
		1.3518691 0.00043311666 3.6887613e-08 1.3518691 0.00043311666 3.6887613e-08;
	setAttr -s 17 ".vt[0:16]"  -1.43306196 5.14824009 -6.27991199 -1.30711484 0.31141102 -8.79994965
		 -0.99509317 -4.90139389 -6.27993011 -0.96786362 -7.053655624 -1.3221422e-05 -0.99509317 -4.90141582 6.27991199
		 -1.30711484 0.31137908 8.79994965 -1.43306196 5.1482172 6.27993488 -1.74368739 6.983922 1.320529e-05
		 -2.35571957 0.16459365 0 0.0034928322 8.31521797 1.5899433e-05 0.32947409 6.20793772 7.35755968
		 0.6841321 0.48583448 10.25982571 0.80052662 -5.84278965 7.46578264 0.83050489 -8.43200874 -1.5841209e-05
		 0.80052662 -5.84276247 -7.46580505 0.6841321 0.48587191 -10.25982475 0.32947409 6.20796442 -7.35753489;
	setAttr -s 32 ".ed[0:31]"  0 1 0 1 2 0 2 3 0 3 4 0 4 5 0 5 6 0 6 7 0
		 7 0 0 0 8 0 1 8 0 2 8 0 3 8 0 4 8 0 5 8 0 6 8 0 7 8 0 9 7 0 10 6 0 9 10 0 11 5 0
		 10 11 0 12 4 0 11 12 0 13 3 0 12 13 0 14 2 0 13 14 0 15 1 0 14 15 0 16 0 0 15 16 0
		 16 9 0;
	setAttr -s 16 -ch 56 ".fc[0:15]" -type "polyFaces" 
		f 3 0 9 -9
		mu 0 3 0 1 2
		f 3 1 10 -10
		mu 0 3 1 3 4
		f 3 2 11 -11
		mu 0 3 3 5 6
		f 3 3 12 -12
		mu 0 3 5 7 8
		f 3 4 13 -13
		mu 0 3 7 9 10
		f 3 5 14 -14
		mu 0 3 9 11 12
		f 3 6 15 -15
		mu 0 3 11 13 14
		f 3 7 8 -16
		mu 0 3 13 15 16
		f 4 -19 16 -7 -18
		mu 0 4 17 18 13 11
		f 4 -21 17 -6 -20
		mu 0 4 19 17 11 9
		f 4 -23 19 -5 -22
		mu 0 4 20 19 9 7
		f 4 -25 21 -4 -24
		mu 0 4 21 20 7 5
		f 4 -27 23 -3 -26
		mu 0 4 22 21 5 3
		f 4 -29 25 -2 -28
		mu 0 4 23 22 3 1
		f 4 -31 27 -1 -30
		mu 0 4 24 23 1 0
		f 4 -32 29 -8 -17
		mu 0 4 18 25 15 13;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_head" -p "ctrl_neck";
	rename -uid "9D2DB031-499B-DB1D-F861-06B508B2D218";
	setAttr ".t" -type "double3" 1.3518690992896296 0.00043311666405854155 3.688761477937342e-08 ;
	setAttr ".s" -type "double3" 1 0.99999999999999989 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005001e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 7.8886090522101172e-31 0 ;
createNode transform -n "offset_head" -p "prnt_head";
	rename -uid "7D9AA788-4F7A-0B10-FD70-C8B109467CFA";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_head" -p "offset_head";
	rename -uid "B761AE35-43CD-BA0F-EF31-619D87B5F693";
	addAttr -ci true -sn "Follow" -ln "Follow" -min 0 -max 1 -en "Neck:World" -at "enum";
	setAttr ".s" -type "double3" 1 1.0000000000000002 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 7.1054273576010019e-15 -1.3322676295501882e-15 -3.3881317890172021e-21 ;
	setAttr ".sp" -type "double3" 7.1054273576010019e-15 -1.3322676295501878e-15 -3.3881317890172014e-21 ;
	setAttr ".spt" -type "double3" 0 -3.9443045261050599e-31 -7.5231638452626417e-37 ;
	setAttr -k on ".Follow" 1;
createNode mesh -n "ctrl_headShape" -p "ctrl_head";
	rename -uid "C6B37E5B-43A9-D150-125A-E2A20D2BC739";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:55]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.5 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 71 ".uvst[0].uvsp[0:70]" -type "float2" 0 0.125 0.125 0.125
		 0.125 0.25 0 0.25 0.25 0.125 0.25 0.25 0.375 0.125 0.375 0.25 0.5 0.125 0.5 0.25
		 0.625 0.125 0.625 0.25 0.75 0.125 0.75 0.25 0.875 0.125 0.875 0.25 1 0.125 1 0.25
		 0.125 0.375 0 0.375 0.25 0.375 0.375 0.375 0.5 0.375 0.625 0.375 0.75 0.375 0.875
		 0.375 1 0.375 0.125 0.5 0 0.5 0.25 0.5 0.375 0.5 0.5 0.5 0.625 0.5 0.75 0.5 0.875
		 0.5 1 0.5 0.125 0.625 0 0.625 0.25 0.625 0.375 0.625 0.5 0.625 0.625 0.625 0.75 0.625
		 0.875 0.625 1 0.625 0.125 0.75 0 0.75 0.25 0.75 0.375 0.75 0.5 0.75 0.625 0.75 0.75
		 0.75 0.875 0.75 1 0.75 0.125 0.85651201 0 0.85651201 0.25 0.85651201 0.375 0.85651201
		 0.5 0.85651201 0.625 0.85651201 0.75 0.85651201 0.875 0.85651201 1 0.85651201 0.0625
		 0 0.1875 0 0.3125 0 0.4375 0 0.5625 0 0.6875 0 0.8125 0 0.9375 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 56 ".pt[1:56]" -type "float3"  0 -4.4408921e-16 0 0 -4.4408921e-16 
		0 0 0 0 0 -4.4408921e-16 0 0 -4.4408921e-16 0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 
		0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 0 
		0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 0 0 0 0 -0.088894896 -0.0015129803 -2.7563107e-09 
		0 -4.4408921e-16 0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 0 -0.088894896 -0.0015129803 
		-2.7563107e-09 -0.0010879139 -1.8515137e-05 -3.3731549e-11 -0.53110766 -0.0090393918 
		-1.6467737e-08 0 -4.4408921e-16 0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 0 -0.53110766 
		-0.0090393918 -1.6467737e-08 0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 0 0 0 0 0 0 0 0 -4.4408921e-16 
		0 0 0 0 0 0 0 0 -4.4408921e-16 -8.4703295e-22 0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 
		0 0 0 0 0 0 0 0 -4.4408921e-16 0 0 0 0;
	setAttr -s 57 ".vt[0:56]"  32.11322021 4.94825268 -5.04044342 32.21178436 0.67161179 -7.12827301
		 32.26350403 -3.56084609 -5.040458679 32.26970673 -5.32203484 -7.6293945e-06 32.26350403 -3.56086445 5.04044342
		 32.21178436 0.67158556 7.12827301 32.11322021 4.94823456 5.040458679 32.055522919 6.67133617 1.5258789e-05
		 28.36250496 8.70728207 -9.68110657 28.58015251 0.39732075 -13.60933685 28.64599228 -7.94891357 -9.68113708
		 28.61867714 -11.3510437 -2.2888184e-05 28.64599228 -7.94894981 9.68110657 28.58015251 0.39727116 13.60933685
		 28.36250496 8.70724678 9.68113708 28.21903229 12.089586258 2.2888184e-05 22.83344078 11.29795837 -12.92930603
		 23.072027206 0.63465881 -18.20953369 23.21245766 -10.97123623 -12.92934418 23.22666359 -15.44975853 -3.0517578e-05
		 23.21245766 -10.97128391 12.92930603 23.072027206 0.63459206 18.20953369 22.83344078 11.29791069 12.92935181
		 22.68709183 15.75454903 3.0517578e-05 16.51222992 13.25790691 -15.2481842 16.73083115 1.44835472 -21.16618347
		 16.95251846 -12.61109924 -15.25445557 17.02779007 -18.032117844 -3.0517578e-05 16.95251846 -12.61115551 15.25440216
		 16.73083115 1.44827652 21.16618729 16.51222992 13.2578516 15.24822998 15.9552269 18.0083770752 3.0517578e-05
		 9.77066231 14.060379028 -16.21211243 10.040195465 1.83749199 -22.080787659 10.29646301 -13.010122299 -16.22180939
		 10.40464592 -18.91625595 -3.8146973e-05 10.29646301 -13.010181427 16.2217598 10.040195465 1.83741188 22.080795288
		 9.77066231 14.060319901 16.21216202 8.5437479 18.53185463 3.0517578e-05 2.63698769 11.91044807 -13.17493439
		 3.40673876 1.34189415 -18.10159302 3.91775894 -11.15873241 -13.95205688 4.0047302246 -16.15977097 -3.0517578e-05
		 3.91775894 -11.15878391 13.95201111 3.40673876 1.34182739 18.10160065 2.63698769 11.91039753 13.17497253
		 1.81469631 15.44985771 3.0517578e-05 33.25531006 0.8092199 0 -0.47078025 11.16551495 2.1526859e-05
		 0.069476485 8.22514915 9.71106625 0.64850664 0.65842766 13.53799152 0.84343207 -7.71642828 9.83927631
		 0.90106457 -11.21818733 -2.0947029e-05 0.84343207 -7.71639633 -9.83930779 0.64850664 0.65847695 -13.53798962
		 0.069476485 8.2251873 -9.71103573;
	setAttr -s 112 ".ed[0:111]"  0 1 0 1 2 0 2 3 0 3 4 0 4 5 0 5 6 0 6 7 0
		 7 0 0 8 9 0 9 10 0 10 11 0 11 12 0 12 13 0 13 14 0 14 15 0 15 8 0 16 17 0 17 18 0
		 18 19 0 19 20 0 20 21 0 21 22 0 22 23 0 23 16 0 24 25 0 25 26 0 26 27 0 27 28 0 28 29 0
		 29 30 0 30 31 0 31 24 0 32 33 0 33 34 0 34 35 0 35 36 0 36 37 0 37 38 0 38 39 0 39 32 0
		 40 41 0 41 42 0 42 43 0 43 44 0 44 45 0 45 46 0 46 47 0 47 40 0 0 8 0 1 9 0 2 10 0
		 3 11 0 4 12 0 5 13 0 6 14 0 7 15 0 8 16 0 9 17 0 10 18 0 11 19 0 12 20 0 13 21 0
		 14 22 0 15 23 0 16 24 0 17 25 0 18 26 0 19 27 0 20 28 0 21 29 0 22 30 0 23 31 0 24 32 0
		 25 33 0 26 34 0 27 35 0 28 36 0 29 37 0 30 38 0 31 39 0 32 40 0 33 41 0 34 42 0 35 43 0
		 36 44 0 37 45 0 38 46 0 39 47 0 40 56 0 41 55 0 42 54 0 43 53 0 44 52 0 45 51 0 46 50 0
		 47 49 0 48 0 0 48 1 0 48 2 0 48 3 0 48 4 0 48 5 0 48 6 0 48 7 0 49 50 0 50 51 0 51 52 0
		 52 53 0 53 54 0 54 55 0 55 56 0 56 49 0;
	setAttr -s 56 -ch 216 ".fc[0:55]" -type "polyFaces" 
		f 4 0 49 -9 -49
		mu 0 4 0 1 2 3
		f 4 1 50 -10 -50
		mu 0 4 1 4 5 2
		f 4 2 51 -11 -51
		mu 0 4 4 6 7 5
		f 4 3 52 -12 -52
		mu 0 4 6 8 9 7
		f 4 4 53 -13 -53
		mu 0 4 8 10 11 9
		f 4 5 54 -14 -54
		mu 0 4 10 12 13 11
		f 4 6 55 -15 -55
		mu 0 4 12 14 15 13
		f 4 7 48 -16 -56
		mu 0 4 14 16 17 15
		f 4 8 57 -17 -57
		mu 0 4 3 2 18 19
		f 4 9 58 -18 -58
		mu 0 4 2 5 20 18
		f 4 10 59 -19 -59
		mu 0 4 5 7 21 20
		f 4 11 60 -20 -60
		mu 0 4 7 9 22 21
		f 4 12 61 -21 -61
		mu 0 4 9 11 23 22
		f 4 13 62 -22 -62
		mu 0 4 11 13 24 23
		f 4 14 63 -23 -63
		mu 0 4 13 15 25 24
		f 4 15 56 -24 -64
		mu 0 4 15 17 26 25
		f 4 16 65 -25 -65
		mu 0 4 19 18 27 28
		f 4 17 66 -26 -66
		mu 0 4 18 20 29 27
		f 4 18 67 -27 -67
		mu 0 4 20 21 30 29
		f 4 19 68 -28 -68
		mu 0 4 21 22 31 30
		f 4 20 69 -29 -69
		mu 0 4 22 23 32 31
		f 4 21 70 -30 -70
		mu 0 4 23 24 33 32
		f 4 22 71 -31 -71
		mu 0 4 24 25 34 33
		f 4 23 64 -32 -72
		mu 0 4 25 26 35 34
		f 4 24 73 -33 -73
		mu 0 4 28 27 36 37
		f 4 25 74 -34 -74
		mu 0 4 27 29 38 36
		f 4 26 75 -35 -75
		mu 0 4 29 30 39 38
		f 4 27 76 -36 -76
		mu 0 4 30 31 40 39
		f 4 28 77 -37 -77
		mu 0 4 31 32 41 40
		f 4 29 78 -38 -78
		mu 0 4 32 33 42 41
		f 4 30 79 -39 -79
		mu 0 4 33 34 43 42
		f 4 31 72 -40 -80
		mu 0 4 34 35 44 43
		f 4 32 81 -41 -81
		mu 0 4 37 36 45 46
		f 4 33 82 -42 -82
		mu 0 4 36 38 47 45
		f 4 34 83 -43 -83
		mu 0 4 38 39 48 47
		f 4 35 84 -44 -84
		mu 0 4 39 40 49 48
		f 4 36 85 -45 -85
		mu 0 4 40 41 50 49
		f 4 37 86 -46 -86
		mu 0 4 41 42 51 50
		f 4 38 87 -47 -87
		mu 0 4 42 43 52 51
		f 4 39 80 -48 -88
		mu 0 4 43 44 53 52
		f 4 40 89 110 -89
		mu 0 4 46 45 54 55
		f 4 41 90 109 -90
		mu 0 4 45 47 56 54
		f 4 42 91 108 -91
		mu 0 4 47 48 57 56
		f 4 43 92 107 -92
		mu 0 4 48 49 58 57
		f 4 44 93 106 -93
		mu 0 4 49 50 59 58
		f 4 45 94 105 -94
		mu 0 4 50 51 60 59
		f 4 46 95 104 -95
		mu 0 4 51 52 61 60
		f 4 47 88 111 -96
		mu 0 4 52 53 62 61
		f 3 -1 -97 97
		mu 0 3 1 0 63
		f 3 -2 -98 98
		mu 0 3 4 1 64
		f 3 -3 -99 99
		mu 0 3 6 4 65
		f 3 -4 -100 100
		mu 0 3 8 6 66
		f 3 -5 -101 101
		mu 0 3 10 8 67
		f 3 -6 -102 102
		mu 0 3 12 10 68
		f 3 -7 -103 103
		mu 0 3 14 12 69
		f 3 -8 -104 96
		mu 0 3 16 14 70;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_r_ear_01" -p "ctrl_head";
	rename -uid "AE5CF5CB-40F6-9D1A-BE75-77BBC92E6C02";
	setAttr ".t" -type "double3" 27.418355863085864 -2.7953044747210627 -9.915675092480587 ;
	setAttr ".r" -type "double3" 89.999882071838101 -27.90473847994625 -176.72190984765868 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".rpt" -type "double3" -1.6599601788685583e-15 3.4576451648400353e-15 -3.139628746485834e-15 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_r_ear_01" -p "prnt_r_ear_01";
	rename -uid "B13B0383-4121-A08D-E3D1-3BB91100EABB";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_r_ear_01" -p "offset_r_ear_01";
	rename -uid "C810FF21-4F62-B560-1494-629384BC3FA0";
	setAttr ".rp" -type "double3" -8.3550416718480847e-07 -4.3893777501580189e-09 8.1791729833469162e-08 ;
	setAttr ".sp" -type "double3" -8.3550416718480847e-07 -4.3893777501580189e-09 8.1791729833469162e-08 ;
createNode mesh -n "ctrl_r_ear_0Shape1" -p "ctrl_r_ear_01";
	rename -uid "336BD298-45E7-3759-3FF9-B9BAA873CA2A";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:5]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 20 ".uvst[0].uvsp[0:19]" -type "float2" 0.375 0.37233591
		 0.375 0.5 0.5026207 0.5 0.5026207 0.37233591 0.375 0.75 0.375 0.87766409 0.5026207
		 0.87766409 0.5026207 0.75 0.74733591 0.25 0.875 0.25 0.875 0 0.74733591 0 0.125 0
		 0.125 0.25 0.25266406 0.25 0.25266406 0 0.625 0.5 0.625 0.37233591 0.625 0.87766409
		 0.625 0.75;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  11.874535 8.0882959 -92.677132 
		-5.6496873 8.8290539 -77.53788 10.114433 10.542128 -101.12675 -7.619925 11.575833 
		-86.996254 3.4986494 7.6718807 -82.212784 0.56806505 11.757522 -96.281448 -12.684081 
		14.551482 -94.192772 -7.5388174 14.809008 -100.62819 -1.4747055 14.319715 -104.89087 
		-1.1905702 13.086028 -100.01732 -7.0364871 12.647374 -92.093544 -12.366029 13.170518 
		-88.737419;
	setAttr -s 12 ".vt[0:11]"  -9.77859879 -15.36830902 85.19029236 5.87889671 -17.25185394 85.67636108
		 -9.88052368 -4.21282816 93.21559143 5.76480198 -4.7646246 94.65974426 -1.7527101 -19.94199371 82.8398056
		 -1.92241931 -1.36810517 96.2019577 3.87108064 -10.15406036 99.7591629 -1.19037199 -7.85941505 101.083976746
		 -6.94644642 -10.33839035 99.65274048 -6.89657068 -18.37054825 95.01537323 -1.10732579 -21.93262482 92.9588089
		 3.92691207 -19.14510536 94.5681839;
	setAttr -s 18 ".ed[0:17]"  0 4 0 2 5 0 0 2 0 1 3 0 2 8 0 3 6 0 4 1 0
		 5 3 0 5 7 1 6 7 0 7 8 0 9 0 0 8 9 0 10 4 1 9 10 0 11 1 0 10 11 0 11 6 0;
	setAttr -s 6 -ch 24 ".fc[0:5]" -type "polyFaces" 
		f 4 11 0 -14 -15
		mu 0 4 0 1 2 3
		f 4 4 -11 -9 -2
		mu 0 4 4 5 6 7
		f 4 15 3 5 -18
		mu 0 4 8 9 10 11
		f 4 -3 -12 -13 -5
		mu 0 4 12 13 14 15
		f 4 13 6 -16 -17
		mu 0 4 3 2 16 17
		f 4 -10 -6 -8 8
		mu 0 4 6 18 19 7;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_r_ear_02" -p "ctrl_r_ear_01";
	rename -uid "CE36D28E-47DF-527E-58A0-F1A05F6DBA9A";
	setAttr ".t" -type "double3" -8.4454408262684098 -0.52916621492280314 -0.030270579499098282 ;
	setAttr ".s" -type "double3" 1 0.99999999999999989 1 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005001e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 7.8886090522101172e-31 0 ;
createNode transform -n "offset_r_ear_02" -p "prnt_r_ear_02";
	rename -uid "4B3E1DE7-4429-E8B4-137A-B6B7F64D2F14";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_r_ear_02" -p "offset_r_ear_02";
	rename -uid "B5F50FCD-41A9-4ACB-9BD6-8A8911ADEDBE";
	setAttr ".rp" -type "double3" 2.0130435416376713e-06 -1.2594488936201742e-06 4.1569651720863021e-08 ;
	setAttr ".sp" -type "double3" 2.0130435416376713e-06 -1.2594488936201742e-06 4.1569651720863021e-08 ;
createNode mesh -n "ctrl_r_ear_0Shape2" -p "ctrl_r_ear_02";
	rename -uid "F90C0A35-4A3F-EE21-07B1-86A1300D8677";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 19 ".uvst[0].uvsp[0:18]" -type "float2" 0.375 0 0.375 0.25
		 0.5026207 0.25 0.5026207 0 0.625 0.25 0.625 0 0.5026207 1 0.625 1 0.625 0.88500339
		 0.5026207 0.88500339 0.375 1 0.375 0.88500339 0.26000336 0.25 0.26000336 0 0.5026207
		 0.36499661 0.375 0.36499661 0.625 0.36499661 0.73999661 0.25 0.73999661 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  -3.6564426 18.247026 -108.0362 
		-10.074142 18.387794 -101.94506 -3.4732699 17.573524 -105.40481 -9.8690996 17.633888 
		-98.999527 -10.00502 18.647034 -103.10327 -10.310005 19.768415 -107.48454 -4.5887294 
		15.279055 -94.629402 0.23370388 15.603957 -101.01106 6.333179 15.052747 -105.05111 
		6.6112585 13.852666 -100.31207 0.72419304 13.504732 -92.725601 -4.2774525 13.935707 
		-89.324615;
	setAttr -s 12 ".vt[0:11]"  -4.13482571 -15.968853 105.40649414 2.056395054 -15.81054783 105.49789429
		 -4.13482571 -20.35049248 102.87675476 2.056395054 -20.71526718 102.66615295 -0.48887718 -23.80679131 104.16639709
		 -0.48887718 -16.51137352 108.37841034 3.7622118 -10.49341011 100.10344696 -1.14828706 -8.37847328 101.52159119
		 -6.77776861 -10.67617989 99.9979248 -6.73088551 -18.4893322 95.48699951 -1.070223331 -22.045063019 93.63118744
		 3.81469393 -19.23930359 95.054000854;
	setAttr -s 19 ".ed[0:18]"  0 5 0 2 4 0 0 2 0 1 3 0 2 9 0 3 11 0 4 3 0
		 4 10 1 5 1 0 5 4 1 6 1 0 7 5 1 6 7 0 8 0 0 7 8 0 8 9 0 9 10 0 10 11 0 11 6 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 2 1 -10 -1
		mu 0 4 0 1 2 3
		f 4 6 -4 -9 9
		mu 0 4 2 4 5 3
		f 4 8 -11 12 11
		mu 0 4 6 7 8 9
		f 4 0 -12 14 13
		mu 0 4 10 6 9 11
		f 4 -5 -3 -14 15
		mu 0 4 12 1 0 13
		f 4 -8 -2 4 16
		mu 0 4 14 2 1 15
		f 4 -6 -7 7 17
		mu 0 4 16 4 2 14
		f 4 3 5 18 10
		mu 0 4 5 4 17 18;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_l_ear_01" -p "ctrl_head";
	rename -uid "EC865199-4FC3-22A5-2A27-C4B91168C54F";
	setAttr ".t" -type "double3" 27.418378695162616 -2.7953364172719111 9.9156641694941303 ;
	setAttr ".r" -type "double3" 90.000117915217402 -27.904750417222434 3.2779797769337109 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".rpt" -type "double3" 1.6599601788660348e-15 3.6477936323008984e-15 -3.139628400075014e-15 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_l_ear_01" -p "prnt_l_ear_01";
	rename -uid "DB2903C6-425A-575E-95AD-0C996331DCFC";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_l_ear_01" -p "offset_l_ear_01";
	rename -uid "B76C7489-482A-622B-7A8B-B4BEAFD3C083";
	setAttr ".rp" -type "double3" 7.1629578712872899e-07 -1.7653128026040577e-07 1.3827644806951866e-07 ;
	setAttr ".sp" -type "double3" 7.1629578712872899e-07 -1.7653128026040577e-07 1.3827644806951866e-07 ;
createNode mesh -n "ctrl_l_ear_0Shape1" -p "ctrl_l_ear_01";
	rename -uid "ADB5FC8E-4F9D-FF1C-7C19-70BB7B36514A";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:5]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 20 ".uvst[0].uvsp[0:19]" -type "float2" 0.375 0.37233591
		 0.5026207 0.37233591 0.5026207 0.5 0.375 0.5 0.375 0.75 0.5026207 0.75 0.5026207
		 0.87766409 0.375 0.87766409 0.74733591 0.25 0.74733591 0 0.875 0 0.875 0.25 0.125
		 0 0.25266406 0 0.25266406 0.25 0.125 0.25 0.625 0.37233591 0.625 0.5 0.625 0.75 0.625
		 0.87766409;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  7.6826434 -8.0882845 -77.703453 
		-6.1081262 -8.8290424 -93.814835 9.646595 -10.542115 -85.30442 -3.9096987 -11.575822 
		-102.32323 0.0067509511 -7.6718693 -83.46682 3.2767537 -11.75751 -96.122467 4.9418998 
		-14.551471 -105.32555 9.9195414 -14.808996 -101.53976 15.367579 -14.319704 -94.414612 
		14.983691 -13.086017 -90.013428 9.2511187 -12.647362 -93.824074 4.5121846 -13.170506 
		-100.39895;
	setAttr -s 12 ".vt[0:11]"  -9.77859879 15.36830902 85.19029236 5.87889671 17.25185394 85.67636108
		 -9.88052368 4.21282816 93.21559143 5.76480198 4.7646246 94.65974426 -1.7527101 19.94199371 82.8398056
		 -1.92241931 1.36810517 96.2019577 3.87108064 10.15406036 99.7591629 -1.19037199 7.85941505 101.083976746
		 -6.94644642 10.33839035 99.65274048 -6.89657068 18.37054825 95.01537323 -1.10732579 21.93262482 92.9588089
		 3.92691207 19.14510536 94.5681839;
	setAttr -s 18 ".ed[0:17]"  0 4 0 2 5 0 0 2 0 1 3 0 2 8 0 3 6 0 4 1 0
		 5 3 0 5 7 1 6 7 0 7 8 0 9 0 0 8 9 0 10 4 1 9 10 0 11 1 0 10 11 0 11 6 0;
	setAttr -s 6 -ch 24 ".fc[0:5]" -type "polyFaces" 
		f 4 14 13 -1 -12
		mu 0 4 0 1 2 3
		f 4 1 8 10 -5
		mu 0 4 4 5 6 7
		f 4 17 -6 -4 -16
		mu 0 4 8 9 10 11
		f 4 4 12 11 2
		mu 0 4 12 13 14 15
		f 4 16 15 -7 -14
		mu 0 4 1 16 17 2
		f 4 -9 7 5 9
		mu 0 4 6 5 18 19;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_l_ear_02" -p "ctrl_l_ear_01";
	rename -uid "976438A3-480C-0ACD-67E4-0EBBB6288F58";
	setAttr ".t" -type "double3" 8.4454530738342584 0.52919787187837386 0.030274283075757857 ;
	setAttr ".s" -type "double3" 1 0.99999999999999989 1 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005001e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 7.8886090522101172e-31 0 ;
createNode transform -n "offset_l_ear_02" -p "prnt_l_ear_02";
	rename -uid "3A4D3C4E-4599-A652-C963-BBA993FBAC37";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_l_ear_02" -p "offset_l_ear_02";
	rename -uid "139C4461-489E-DB5E-93D7-9FB1E447A11F";
	setAttr ".rp" -type "double3" 1.1144695548637173e-06 -1.0136049581888074e-06 4.8312100098257815e-08 ;
	setAttr ".sp" -type "double3" 1.1144695548637173e-06 -1.0136049581888074e-06 4.8312100098257815e-08 ;
createNode mesh -n "ctrl_l_ear_0Shape2" -p "ctrl_l_ear_02";
	rename -uid "8F0DA275-44A9-35D2-D40F-2BB667984C66";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 19 ".uvst[0].uvsp[0:18]" -type "float2" 0.375 0 0.5026207
		 0 0.5026207 0.25 0.375 0.25 0.625 0 0.625 0.25 0.5026207 1 0.5026207 0.88500339 0.625
		 0.88500339 0.625 1 0.375 1 0.375 0.88500339 0.26000336 0.25 0.26000336 0 0.5026207
		 0.36499661 0.375 0.36499661 0.625 0.36499661 0.73999661 0 0.73999661 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  11.926062 -18.247047 -102.77679 
		5.961319 -18.387814 -109.05074 11.742889 -17.573545 -100.3487 5.7562776 -17.633907 
		-106.33278 10.982742 -18.647055 -105.22952 11.287727 -19.768436 -109.27229 -2.9357264 
		-15.279075 -105.57749 2.0628381 -15.603977 -102.03212 7.2223263 -15.052767 -94.94474 
		6.8504806 -13.852686 -90.661926 1.4162214 -13.504752 -94.536781 -3.3519676 -13.935726 
		-100.78339;
	setAttr -s 12 ".vt[0:11]"  -4.13482571 15.968853 105.40649414 2.056395054 15.81054783 105.49789429
		 -4.13482571 20.35049248 102.87675476 2.056395054 20.71526718 102.66615295 -0.48887718 23.80679131 104.16639709
		 -0.48887718 16.51137352 108.37841034 3.7622118 10.49341011 100.10344696 -1.14828706 8.37847328 101.52159119
		 -6.77776861 10.67617989 99.9979248 -6.73088551 18.4893322 95.48699951 -1.070223331 22.045063019 93.63118744
		 3.81469393 19.23930359 95.054000854;
	setAttr -s 19 ".ed[0:18]"  0 5 0 2 4 0 0 2 0 1 3 0 2 9 0 3 11 0 4 3 0
		 4 10 1 5 1 0 5 4 1 6 1 0 7 5 1 6 7 0 8 0 0 7 8 0 8 9 0 9 10 0 10 11 0 11 6 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 0 9 -2 -3
		mu 0 4 0 1 2 3
		f 4 -10 8 3 -7
		mu 0 4 2 1 4 5
		f 4 -12 -13 10 -9
		mu 0 4 6 7 8 9
		f 4 -14 -15 11 -1
		mu 0 4 10 11 7 6
		f 4 -16 13 2 4
		mu 0 4 12 13 0 3
		f 4 -17 -5 1 7
		mu 0 4 14 15 3 2
		f 4 -18 -8 6 5
		mu 0 4 16 14 2 5
		f 4 -11 -19 -6 -4
		mu 0 4 4 17 18 5;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode parentConstraint -n "prnt_head_parentConstraint1" -p "prnt_head";
	rename -uid "F5B27D8E-4424-2AA4-10C6-0CA69A95F9D2";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_rootW0" -dv 1 -min 0 -at "double";
	addAttr -dcb 0 -ci true -k true -sn "w1" -ln "ctrl_neckW1" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr -s 2 ".tg";
	setAttr ".tg[0].tot" -type "double3" 62.77768368000001 1.1750374489999758 -4.7298534590984415e-14 ;
	setAttr ".tg[0].tor" -type "double3" -0.00010438000040056147 -9.7581641943124454e-15 
		-0.97507344000000173 ;
	setAttr ".tg[1].tot" -type "double3" 2.8421709430404004e-14 -2.2204460492503123e-15 
		2.5410988417629018e-21 ;
	setAttr ".lr" -type "double3" 2.0334108819098992e-13 -6.3633425662277248e-15 -7.9514446665478151e-16 ;
	setAttr ".rst" -type "double3" 1.3518690992896367 0.00043311666405898563 3.6887614779374267e-08 ;
	setAttr ".rsrr" -type "double3" -2.1371712933070277e-21 4.879081907588487e-15 4.4442939510737615e-21 ;
	setAttr -k on ".w0";
	setAttr -k on ".w1";
createNode transform -n "grp_r_arm" -p "ctrl_spine_03";
	rename -uid "72FDBED4-423A-4069-EEFB-C5838F4D1FD1";
	setAttr ".t" -type "double3" -54.4979472239839 -2.9791997083578026 0.0021590183724247555 ;
	setAttr ".r" -type "double3" 90.002016894818425 -0.00015085679160630825 91.662132431344915 ;
createNode transform -n "prnt_r_clavicle" -p "grp_r_arm";
	rename -uid "610B1073-4027-6E7C-3F10-55B4B8A2C74F";
	setAttr ".t" -type "double3" 7.448344829796838e-09 -3.5521499999999975 55.7362 ;
	setAttr ".r" -type "double3" 0 -8.7424967400000018 90 ;
	setAttr ".s" -type "double3" 0.99999999999999944 0.99999999999999978 1 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509373e-16 0 ;
	setAttr ".rpt" -type "double3" 6.6613381477509373e-16 6.6613381477509392e-16 1.2325951644078309e-32 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".spt" -type "double3" 0 1.9721522630525291e-31 0 ;
createNode transform -n "offset_r_clavicle" -p "prnt_r_clavicle";
	rename -uid "A26E082B-44AD-8DA6-75F5-3D90E098BE3A";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_r_clavicle" -p "offset_r_clavicle";
	rename -uid "BB56F5A3-47B4-6244-DA64-ED9309FA50FD";
	setAttr ".rp" -type "double3" -2.5028003314275793e-07 -5.7127103048060318e-10 -1.5547297209650424e-06 ;
	setAttr ".sp" -type "double3" -2.5028003314275793e-07 -5.7127103048060318e-10 -1.5547297209650424e-06 ;
createNode mesh -n "ctrl_r_clavicleShape" -p "ctrl_r_clavicle";
	rename -uid "454127B5-4AC8-78C3-A420-79A3326FFE9C";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:15]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 30 ".uvst[0].uvsp[0:29]" -type "float2" 0.375 0 0.375 0.125
		 0.45833334 0.125 0.45833334 0 0.54166669 0.125 0.54166669 0 0.625 0.125 0.625 0 0.375
		 0.25 0.45833334 0.25 0.54166669 0.25 0.625 0.25 0.375 0.5 0.45833334 0.5 0.54166669
		 0.5 0.625 0.5 0.375 0.75 0.375 1 0.45833334 1 0.45833334 0.75 0.54166669 1 0.54166669
		 0.75 0.625 1 0.625 0.75 0.875 0.125 0.875 0 0.875 0.25 0.125 0 0.125 0.125 0.125
		 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 22 ".pt[0:21]" -type "float3"  -0.79931647 13.018058 -54.951515 
		-3.9360325 9.5789957 -54.974628 -7.2884097 6.2266183 -54.974628 -10.856448 2.9609256 
		-54.951515 -1.9829751 15.038777 -54.70657 -6.1934228 11.705322 -54.63953 -9.5458002 
		8.3529453 -54.63953 -12.995717 4.0260348 -54.70657 -4.0121508 15.960074 -54.481033 
		-8.1475716 13.435534 -54.357895 -11.499949 10.083158 -54.357895 -14.069283 5.9029422 
		-54.481033 -3.7099557 15.565326 -54.534306 -7.8453765 13.040786 -54.411171 -11.197754 
		9.6884089 -54.411171 -13.767087 5.5081935 -54.534306 -1.6807801 14.644029 -54.759846 
		-12.693522 3.6312861 -54.759846 -0.49712139 12.623309 -55.004791 -3.6338367 9.184247 
		-55.027901 -6.9862142 5.8318696 -55.027901 -10.554254 2.5661769 -55.004791;
	setAttr -s 22 ".vt[0:21]"  -3.84085608 -9.17720127 61.78593826 -0.48847866 -9.090517044 62.64113235
		 2.86389875 -9.090517044 62.64113235 6.21627569 -9.17720127 61.78593826 -4.31866121 -10.72011566 60.88803482
		 -0.48847866 -11.21684361 61.61629868 2.86389875 -11.21684361 61.61629868 6.69408083 -10.72011566 60.88803482
		 -3.84085608 -12.11921787 59.77928162 -0.48847866 -12.94705582 60.01071167 2.86389875 -12.94705582 60.01071167
		 6.21627569 -12.11921787 59.77928162 -3.84085608 -11.72446918 59.20052719 -0.48847866 -12.55230713 59.43195724
		 2.86389875 -12.55230713 59.43195724 6.21627569 -11.72446918 59.20052719 -4.31866121 -10.32536697 60.3092804
		 6.69408083 -10.32536697 60.3092804 -3.84085608 -8.78245258 61.20718384 -0.48847866 -8.69576836 62.062381744
		 2.86389875 -8.69576836 62.062381744 6.21627569 -8.78245258 61.20718384;
	setAttr -s 37 ".ed[0:36]"  0 1 0 1 2 0 2 3 0 4 5 1 5 6 1 6 7 1 8 9 0
		 9 10 0 10 11 0 12 13 0 13 14 0 14 15 0 18 19 0 19 20 0 20 21 0 0 4 0 1 5 1 2 6 1
		 3 7 0 4 8 0 5 9 1 6 10 1 7 11 0 8 12 0 9 13 1 10 14 1 11 15 0 12 16 0 15 17 0 16 18 0
		 17 21 0 18 0 0 19 1 1 20 2 1 21 3 0 17 7 1 16 4 1;
	setAttr -s 16 -ch 64 ".fc[0:15]" -type "polyFaces" 
		f 4 15 3 -17 -1
		mu 0 4 0 1 2 3
		f 4 16 4 -18 -2
		mu 0 4 3 2 4 5
		f 4 17 5 -19 -3
		mu 0 4 5 4 6 7
		f 4 19 6 -21 -4
		mu 0 4 1 8 9 2
		f 4 20 7 -22 -5
		mu 0 4 2 9 10 4
		f 4 21 8 -23 -6
		mu 0 4 4 10 11 6
		f 4 23 9 -25 -7
		mu 0 4 8 12 13 9
		f 4 24 10 -26 -8
		mu 0 4 9 13 14 10
		f 4 25 11 -27 -9
		mu 0 4 10 14 15 11
		f 4 31 0 -33 -13
		mu 0 4 16 17 18 19
		f 4 32 1 -34 -14
		mu 0 4 19 18 20 21
		f 4 33 2 -35 -15
		mu 0 4 21 20 22 23
		f 4 18 -36 30 34
		mu 0 4 7 6 24 25
		f 4 22 26 28 35
		mu 0 4 6 11 26 24
		f 4 -30 36 -16 -32
		mu 0 4 27 28 1 0
		f 4 -28 -24 -20 -37
		mu 0 4 28 29 8 1;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_r_shoulder" -p "ctrl_r_clavicle";
	rename -uid "9B0CAAE1-4F0C-37A5-C24B-E698A7D52B2E";
	setAttr ".t" -type "double3" -3.9696869690919785 1.5159662414365665e-10 -3.1958971042911344e-05 ;
	setAttr ".r" -type "double3" -0.82766214246446412 -14.017145624632791 3.413288659196474 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1 1 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".rpt" -type "double3" 3.7329573570724541e-17 1.1123067241634649e-18 9.335735295800676e-18 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "offset_r_shoulder" -p "prnt_r_shoulder";
	rename -uid "03487008-441D-D181-D435-5EAD349CA4B4";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_r_shoulder" -p "offset_r_shoulder";
	rename -uid "6B8E4AAE-4C15-1F29-F0D6-93BB926E2960";
	setAttr ".rp" -type "double3" 4.8631764748563455e-07 -2.796478026922955e-08 9.4066622580157855e-07 ;
	setAttr ".sp" -type "double3" 4.8631764748563455e-07 -2.796478026922955e-08 9.4066622580157855e-07 ;
createNode mesh -n "ctrl_r_shoulderShape" -p "ctrl_r_shoulder";
	rename -uid "4060394E-492E-DDD1-AC59-2A9B1F382803";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 26 ".uvst[0].uvsp[0:25]" -type "float2" 0.375 0 0.375 0.094423816
		 0.48798609 0.094423816 0.48798609 0 0.375 0.65557623 0.375 0.75 0.48798609 0.75 0.48798609
		 0.65557623 0.375 0.87287432 0.375 1 0.48798609 1 0.48798609 0.87287432 0.625 0 0.625
		 0.094423816 0.75212574 0.094423816 0.75212574 0 0.24787429 0 0.24787429 0.094423808
		 0.125 0 0.125 0.094423808 0.875 0.094423808 0.875 0 0.625 0.75 0.625 0.65557623 0.625
		 0.87287432 0.625 1;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 17 ".pt[0:16]" -type "float3"  3.6366842 12.039894 -54.904751 
		-4.6685553 4.2013202 -54.904751 3.5813396 8.4927988 -55.608917 -4.5092826 0.85678101 
		-55.608917 5.7535238 12.573799 -55.199722 -6.7776136 0.74677402 -55.199722 0.18295951 
		4.6635966 -55.734196 0.77720642 7.8431449 -55.206566 0.043587595 9.2417212 -54.785263 
		-14.443958 11.204967 -51.634674 -12.769276 13.897532 -51.410625 -9.0280075 17.875282 
		-51.320621 -6.1781816 20.117273 -51.410828 -4.4992266 20.590275 -51.634804 -5.6230211 
		18.480639 -51.846157 -8.8652306 14.943652 -51.942257 -13.322201 11.214231 -51.846127;
	setAttr -s 17 ".vt[0:16]"  -3.26297522 -8.7930851 58.74832916 4.58871031 -8.7930851 58.74832916
		 -3.16152692 -5.35027504 50.68603897 4.48726273 -5.35027504 50.68603897 -5.26053619 -7.33298922 55.28217316
		 6.58627033 -7.33298922 55.28217316 0.093560614 -4.77331352 49.42811966 -0.5534842 -7.30168009 55.21445084
		 0.093560614 -9.34337425 59.94809723 5.10940456 -15.78280544 51.52893829 3.52414441 -16.89263153 54.16566849
		 -0.043197442 -17.30713844 55.069396973 -2.70693755 -16.89170074 54.16364288 -4.2921977 -15.7822113 51.5276413
		 -3.22956347 -14.73344803 49.031303406 -0.13196933 -14.29086876 48.066371918 4.049148083 -14.7335968 49.031627655;
	setAttr -s 28 ".ed[0:27]"  0 8 0 2 6 0 0 12 0 1 10 0 2 4 0 3 5 0 4 0 0
		 5 1 0 4 7 1 5 9 1 6 3 0 7 5 1 6 7 1 8 1 0 7 8 1 8 11 1 9 10 0 10 11 0 11 12 0 13 4 1
		 12 13 0 14 2 0 13 14 0 15 6 1 14 15 0 16 3 0 15 16 0 16 9 0;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 2 -19 -16 -1
		mu 0 4 0 1 2 3
		f 4 21 1 -24 -25
		mu 0 4 4 5 6 7
		f 4 6 0 -15 -9
		mu 0 4 8 9 10 11
		f 4 3 -17 -10 7
		mu 0 4 12 13 14 15
		f 4 -20 -21 -3 -7
		mu 0 4 16 17 1 0
		f 4 -22 -23 19 -5
		mu 0 4 18 19 17 16
		f 4 4 8 -13 -2
		mu 0 4 5 8 11 6
		f 4 25 5 9 -28
		mu 0 4 20 21 15 14
		f 4 10 -26 -27 23
		mu 0 4 6 22 23 7
		f 4 11 -6 -11 12
		mu 0 4 11 24 22 6
		f 4 13 -8 -12 14
		mu 0 4 10 25 24 11
		f 4 -18 -4 -14 15
		mu 0 4 2 13 12 3;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_r_elbow" -p "ctrl_r_shoulder";
	rename -uid "F0460864-4580-69B8-BD57-69B2673E2BDC";
	setAttr ".t" -type "double3" -10.564651430036747 -3.5481719828922564e-07 4.5915523052997287e-05 ;
	setAttr ".r" -type "double3" -0.18678661812772507 -2.0409997234261925 1.9185657748085279 ;
	setAttr ".s" -type "double3" 1.0000000000000009 1.0000000000000007 1 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509432e-16 0 ;
	setAttr ".rpt" -type "double3" 2.2224098961815694e-17 3.7436973482620405e-19 2.1702423435001398e-18 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".spt" -type "double3" 0 -3.9443045261050617e-31 0 ;
createNode transform -n "offset_r_elbow" -p "prnt_r_elbow";
	rename -uid "8CCD93A0-41DE-D582-213A-B198D464E039";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_r_elbow" -p "offset_r_elbow";
	rename -uid "D60718D2-41D9-1CEA-F198-32BE476A1D74";
	setAttr ".rp" -type "double3" -4.1806794026655325e-07 4.3239506863912425e-08 2.6176668654898094e-07 ;
	setAttr ".sp" -type "double3" -4.1806794026655325e-07 4.3239506863912425e-08 2.6176668654898094e-07 ;
createNode mesh -n "ctrl_r_elbowShape" -p "ctrl_r_elbow";
	rename -uid "E184A316-4155-0CDC-8F83-19B45FF0F4F3";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 20 ".uvst[0].uvsp[0:19]" -type "float2" 0.625 0.11420364
		 0.625 0.16905998 0.75212574 0.16905998 0.75212574 0.11420364 0.48798609 0.16905998
		 0.48798609 0.11420364 0.375 0.11420364 0.375 0.16905998 0.24787429 0.11420363 0.24787429
		 0.16905996 0.125 0.11420363 0.125 0.16905996 0.375 0.58094001 0.375 0.63579637 0.48798609
		 0.63579637 0.48798609 0.58094001 0.625 0.63579637 0.625 0.58094001 0.875 0.16905996
		 0.875 0.11420363;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 16 ".pt[0:15]" -type "float3"  -5.0096197 12.30501 -51.242142 
		-3.3552437 15.126482 -50.953384 0.13727008 19.428476 -50.708035 2.7427804 21.932566 
		-50.680283 4.1912622 22.578966 -50.829033 3.1244552 20.338448 -51.107952 0.038402192 
		16.571278 -51.317226 -4.1246166 12.509089 -51.375046 -10.930011 17.647728 -48.876171 
		-9.1720448 20.272306 -48.651581 -5.3383241 24.119091 -48.575016 -2.5078299 26.346775 
		-48.653332 -0.87485391 26.81728 -48.87788 -3.4604754 24.60371 -48.845665 -6.1917543 
		21.877214 -48.89711 -9.6143866 18.470167 -48.959469;
	setAttr -s 16 ".vt[0:15]"  5.035866261 -16.75148773 51.10646439 3.45877957 -17.99635887 53.63781357
		 -0.079188593 -18.74145508 54.36859131 -2.72426939 -18.58579826 53.36146927 -4.29326296 -17.64562988 50.69993973
		 -3.24388218 -16.45727921 48.31891632 -0.17252181 -15.77295017 47.47400284 3.97872186 -15.87826157 48.5776329
		 5.33907461 -21.88483047 48.83440399 3.78124595 -22.96338272 51.30428314 0.28626347 -23.33157921 52.14858627
		 -2.3266151 -22.95538139 51.28684616 -3.87661123 -21.87701035 48.81736374 -2.074820995 -21.40105057 46.30715179
		 0.33916581 -21.069595337 45.35805893 3.81244016 -21.15495682 46.42014694;
	setAttr -s 24 ".ed[0:23]"  0 8 1 1 9 0 0 1 0 2 10 1 1 2 0 3 11 0 2 3 0
		 3 4 0 4 5 0 5 6 0 6 7 0 7 0 0 8 9 0 9 10 0 10 11 0 12 4 1 11 12 0 13 5 0 12 13 0
		 14 6 1 13 14 0 15 7 0 14 15 0 15 8 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 1 -13 -1 2
		mu 0 4 0 1 2 3
		f 4 -14 -2 4 3
		mu 0 4 4 1 0 5
		f 4 5 -15 -4 6
		mu 0 4 6 7 4 5
		f 4 -16 -17 -6 7
		mu 0 4 8 9 7 6
		f 4 -18 -19 15 8
		mu 0 4 10 11 9 8
		f 4 17 9 -20 -21
		mu 0 4 12 13 14 15
		f 4 -22 -23 19 10
		mu 0 4 16 17 15 14
		f 4 21 11 0 -24
		mu 0 4 18 19 3 2;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_r_wrist" -p "ctrl_r_elbow";
	rename -uid "DED53D22-4EFE-7512-EAE2-C690F7396468";
	setAttr ".t" -type "double3" -6.2112473296964756 2.2045407277460072e-08 3.3308562642275774e-05 ;
	setAttr ".r" -type "double3" 179.99999830159041 24.833093125441049 0 ;
	setAttr ".s" -type "double3" 0.99999999999999922 0.99999999999999956 1 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509363e-16 0 ;
	setAttr ".rpt" -type "double3" -8.2928936483821388e-24 1.3322676295501871e-15 -1.7920275929012715e-23 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".spt" -type "double3" 0 2.9582283945787934e-31 0 ;
createNode transform -n "offset_r_wrist" -p "prnt_r_wrist";
	rename -uid "8612514E-4D60-E317-B2E0-088DE30802DA";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_r_wrist" -p "offset_r_wrist";
	rename -uid "95607FAB-458D-5C6E-B13A-1986B8AE2F17";
	setAttr ".rp" -type "double3" 8.1380482441772983e-07 1.5519544382947004e-07 -1.846071249644865e-06 ;
	setAttr ".sp" -type "double3" 8.1380482441772983e-07 1.5519544382947004e-07 -1.846071249644865e-06 ;
createNode mesh -n "ctrl_r_wristShape" -p "ctrl_r_wrist";
	rename -uid "040DF317-477E-0320-93C3-B0B3F08C3FA6";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 23 ".uvst[0].uvsp[0:22]" -type "float2" 0.375 0.25 0.3521387
		 0.38790306 0.4861117 0.36525437 0.48798609 0.25 0.375 0.5 0.48798609 0.5 0.625 0.37712568
		 0.625 0.25 0.625 0.5 0.75212574 0.25 0.75212574 0.17429687 0.625 0.17429687 0.48798609
		 0.17429687 0.375 0.17429687 0.24787429 0.17429686 0.23458175 0.25619757 0.125 0.17429686
		 0.125 0.25 0.48798609 0.57570314 0.375 0.57570314 0.625 0.57570314 0.875 0.25 0.875
		 0.17429686;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 17 ".pt[0:16]" -type "float3"  -5.5596671 26.808985 -46.3232 
		-9.833684 30.748087 -46.599709 -4.1270938 25.367685 -39.657749 -8.9047899 29.770815 
		-39.956886 -10.646534 31.415112 -42.190464 -4.4233479 25.681118 -41.871326 -8.0102692 
		29.075554 -46.916218 -8.204154 29.163742 -42.011795 -6.4739318 27.510368 -38.709221 
		-6.1646204 27.398113 -48.077934 -5.5550041 26.928778 -53.06443 -2.1405809 23.819433 
		-54.882034 1.0619019 20.841913 -53.2631 3.814873 18.218361 -48.396206 2.3397615 19.48278 
		-43.325005 0.058603264 21.545921 -41.339466 -3.7853551 25.120644 -43.325508;
	setAttr -s 17 ".vt[0:16]"  -1.32229066 -29.927948 47.3331604 3.10811424 -29.40312576 47.55666351
		 -1.52048838 -28.71107864 43.99638367 3.41140103 -28.14682388 44.24083328 4.14556742 -29.095161438 45.37133026
		 -2.19324231 -29.73748779 45.089889526 0.85202736 -30.024265289 47.67131042 1.012449622 -30.048431396 45.22124863
		 0.86389196 -28.47628403 43.56776047 5.48928261 -23.13330841 48.34658432 3.93238688 -24.20908356 50.81010056
		 0.43947417 -24.57627106 51.65210342 -2.17185044 -24.20108032 50.79266357 -3.72093391 -23.12548256 48.32953262
		 -1.92011809 -22.65324402 45.8278389 0.49237117 -22.3228302 44.88113403 3.96361232 -22.40717316 45.94087982;
	setAttr -s 28 ".ed[0:27]"  0 6 0 2 8 0 0 5 0 1 4 0 2 14 0 3 16 0 4 3 0
		 5 2 0 4 7 1 5 13 1 6 1 0 7 5 1 6 7 1 8 3 0 7 8 1 8 15 1 10 1 0 9 10 0 10 11 0 11 12 0
		 12 13 0 13 14 0 14 15 0 15 16 0 16 9 0 11 6 1 12 0 0 9 4 1;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 2 -12 -13 -1
		mu 0 4 0 1 2 3
		f 4 7 1 -15 11
		mu 0 4 1 4 5 2
		f 4 12 -9 -4 -11
		mu 0 4 3 2 6 7
		f 4 13 -7 8 14
		mu 0 4 5 8 6 2
		f 4 3 -28 17 16
		mu 0 4 7 9 10 11
		f 4 25 10 -17 18
		mu 0 4 12 3 7 11
		f 4 26 0 -26 19
		mu 0 4 13 0 3 12
		f 4 -10 -3 -27 20
		mu 0 4 14 15 0 13
		f 4 -5 -8 9 21
		mu 0 4 16 17 15 14
		f 4 -16 -2 4 22
		mu 0 4 18 5 4 19
		f 4 -6 -14 15 23
		mu 0 4 20 8 5 18
		f 4 27 6 5 24
		mu 0 4 10 9 21 22;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode joint -n "ctrl_j_r_clavicle" -p "grp_r_arm";
	rename -uid "7C892B8C-4C6D-633E-21B4-789C152AF318";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -2.4865205831024666e-16 -8.7424967398755271 89.999999997786261 ;
createNode joint -n "ctrl_j_r_shoulder" -p "ctrl_j_r_clavicle";
	rename -uid "AE18002B-4EEB-2D4F-C505-EE959BF161CA";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.82766214234671753 -14.017145625753047 3.4132886617116309 ;
createNode joint -n "ctrl_j_r_elbow" -p "ctrl_j_r_shoulder";
	rename -uid "31C88C3F-4E0D-C35E-AB1D-C7BDC3CF8DE2";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.18678661639127808 -2.0409997214781423 1.9185657772404567 ;
createNode joint -n "ctrl_j_r_wrist" -p "ctrl_j_r_elbow";
	rename -uid "B473EEC7-4BB7-9771-EBC9-F983AA3DAC45";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 179.99999829245391 24.833093124436278 0 ;
createNode parentConstraint -n "ctrl_j_r_wrist_parentConstraint1" -p "ctrl_j_r_wrist";
	rename -uid "FAEFA09F-4380-FEAE-82E4-358C2DAE33FF";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_wristW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -8.1380482086501615e-07 -1.5519545248920963e-07 
		1.846071249644865e-06 ;
	setAttr ".tg[0].tor" -type "double3" -7.2828665707622154e-09 4.2870696551446751e-11 
		-7.0154366977871892e-15 ;
	setAttr ".lr" -type "double3" 7.127699374472037e-09 9.3536296516224262e-10 2.7875874497574218e-17 ;
	setAttr ".rst" -type "double3" -6.2112473296964943 2.2351299699963079e-08 3.3308458384340156e-05 ;
	setAttr ".rsrr" -type "double3" 7.2828086651777443e-09 -4.2883418770172598e-11 -1.2780020557353713e-18 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_elbow_parentConstraint1" -p "ctrl_j_r_elbow";
	rename -uid "27D7FE77-4E58-1480-626F-B89BB07EB283";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_elbowW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 4.1806794381926693e-07 -4.3239502867109536e-08 
		-2.617666936544083e-07 ;
	setAttr ".tg[0].tor" -type "double3" 1.6822959560678554e-09 9.6188123738827992e-10 
		2.8216457913374627e-09 ;
	setAttr ".lr" -type "double3" -1.8230598518031403e-09 -1.940116387696235e-09 -2.4367303131129276e-09 ;
	setAttr ".rst" -type "double3" -10.564651430036742 -3.5474660142753578e-07 4.591570404244294e-05 ;
	setAttr ".rsrr" -type "double3" -1.682295980892254e-09 -9.6188096837155038e-10 -2.8216455638080775e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_shoulder_parentConstraint1" -p "ctrl_j_r_shoulder";
	rename -uid "9EA80F99-41EF-5524-3472-FC95709552C3";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_shoulderW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -4.8631764393292087e-07 2.7964779603095735e-08 
		-9.4066622580157855e-07 ;
	setAttr ".tg[0].tor" -type "double3" -1.2170710544088296e-10 -9.8160345939869998e-10 
		3.8284972811712642e-10 ;
	setAttr ".lr" -type "double3" -24.069517094964613 -11.592159243338736 -84.67783953832776 ;
	setAttr ".rst" -type "double3" -4.8709779640887518e-06 3.9696867182406681 -3.1605812317536675e-05 ;
	setAttr ".rsrr" -type "double3" -24.069517094964603 -11.59215924333872 -84.677839538327774 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_clavicle_parentConstraint1" -p "ctrl_j_r_clavicle";
	rename -uid "5C1D78B2-44E5-5369-CC8C-46AA57D32AEE";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_clavicleW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -5.7126836594534325e-10 1.106261793282215e-08 
		1.5747070278848696e-06 ;
	setAttr ".tg[0].tor" -type "double3" 1.2591809368316301e-10 -8.7424967398755467 
		89.999999997786276 ;
	setAttr ".lr" -type "double3" -1.2594061928143118e-10 -8.7424967402120188 89.999999999993435 ;
	setAttr ".rst" -type "double3" -3.0430018504753618e-09 -3.5521502509731966 55.736199981617311 ;
	setAttr ".rsrr" -type "double3" -1.2592292059716704e-10 -8.7424967402120188 89.99999999999342 ;
	setAttr -k on ".w0";
createNode transform -n "grp_l_arm" -p "ctrl_spine_03";
	rename -uid "18FD0592-4D25-9C96-C5F9-E08DFE8BF92E";
	setAttr ".t" -type "double3" -54.4979472239839 -2.9791997083578026 0.0021590183724247555 ;
	setAttr ".r" -type "double3" 90.002016894818425 -0.00015085679160630825 91.662132431344915 ;
createNode transform -n "prnt_l_clavicle" -p "grp_l_arm";
	rename -uid "0A6913CB-4C89-826C-3F95-009EC161846E";
	setAttr ".t" -type "double3" 7.4483563759999999e-09 3.5516707490000003 55.736206869999997 ;
	setAttr ".r" -type "double3" -180 8.74249674 90 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "offset_l_clavicle" -p "prnt_l_clavicle";
	rename -uid "13C1AF8A-4D31-EB54-0291-458193F2FB24";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_l_clavicle" -p "offset_l_clavicle";
	rename -uid "740688B9-490E-2CB6-2884-F39806BBAD3F";
	setAttr ".rp" -type "double3" 1.6416809067720806e-07 5.7127724772954025e-10 7.9965064259113205e-07 ;
	setAttr ".sp" -type "double3" 1.6416809067720806e-07 5.7127724772954025e-10 7.9965064259113205e-07 ;
createNode mesh -n "ctrl_l_clavicleShape" -p "ctrl_l_clavicle";
	rename -uid "8C532154-4BF8-FA40-E229-D091CBA4D61D";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:15]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 30 ".uvst[0].uvsp[0:29]" -type "float2" 0.375 0 0.45833334
		 0 0.45833334 0.125 0.375 0.125 0.54166669 0 0.54166669 0.125 0.625 0 0.625 0.125
		 0.45833334 0.25 0.375 0.25 0.54166669 0.25 0.625 0.25 0.45833334 0.5 0.375 0.5 0.54166669
		 0.5 0.625 0.5 0.375 0.75 0.45833334 0.75 0.45833334 1 0.375 1 0.54166669 0.75 0.54166669
		 1 0.625 0.75 0.625 1 0.875 0 0.875 0.125 0.875 0.25 0.125 0 0.125 0.125 0.125 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 22 ".pt[0:21]" -type "float3"  8.4815035 -13.018058 -68.62043 
		4.9134645 -9.5789957 -70.307701 1.5610871 -6.2266183 -70.307701 -1.5756284 -2.9609256 
		-68.62043 10.620772 -15.038777 -67.069565 7.1708546 -11.705322 -68.593132 3.8184774 
		-8.3529453 -68.593132 -0.39196974 -4.0260348 -67.069565 11.694338 -15.960074 -65.077599 
		9.1250038 -13.435534 -65.663597 5.7726264 -10.083158 -65.663597 1.6372058 -5.9029422 
		-65.077599 11.392142 -15.565326 -63.866814 8.8228092 -13.040786 -64.452812 5.4704313 
		-9.6884089 -64.452812 1.3350108 -5.5081935 -63.866814 10.318577 -14.644029 -65.85878 
		-0.69416481 -3.6312861 -65.85878 8.1793079 -12.623309 -67.409645 4.611269 -9.184247 
		-69.096924 1.2588915 -5.8318696 -69.096924 -1.8778235 -2.5661769 -67.409645;
	setAttr -s 22 ".vt[0:21]"  -3.84085608 9.17720127 61.78593826 -0.48847866 9.090517044 62.64113235
		 2.86389875 9.090517044 62.64113235 6.21627569 9.17720127 61.78593826 -4.31866121 10.72011566 60.88803482
		 -0.48847866 11.21684361 61.61629868 2.86389875 11.21684361 61.61629868 6.69408083 10.72011566 60.88803482
		 -3.84085608 12.11921787 59.77928162 -0.48847866 12.94705582 60.01071167 2.86389875 12.94705582 60.01071167
		 6.21627569 12.11921787 59.77928162 -3.84085608 11.72446918 59.20052719 -0.48847866 12.55230713 59.43195724
		 2.86389875 12.55230713 59.43195724 6.21627569 11.72446918 59.20052719 -4.31866121 10.32536697 60.3092804
		 6.69408083 10.32536697 60.3092804 -3.84085608 8.78245258 61.20718384 -0.48847866 8.69576836 62.062381744
		 2.86389875 8.69576836 62.062381744 6.21627569 8.78245258 61.20718384;
	setAttr -s 37 ".ed[0:36]"  0 1 0 1 2 0 2 3 0 4 5 1 5 6 1 6 7 1 8 9 0
		 9 10 0 10 11 0 12 13 0 13 14 0 14 15 0 18 19 0 19 20 0 20 21 0 0 4 0 1 5 1 2 6 1
		 3 7 0 4 8 0 5 9 1 6 10 1 7 11 0 8 12 0 9 13 1 10 14 1 11 15 0 12 16 0 15 17 0 16 18 0
		 17 21 0 18 0 0 19 1 1 20 2 1 21 3 0 17 7 1 16 4 1;
	setAttr -s 16 -ch 64 ".fc[0:15]" -type "polyFaces" 
		f 4 0 16 -4 -16
		mu 0 4 0 1 2 3
		f 4 1 17 -5 -17
		mu 0 4 1 4 5 2
		f 4 2 18 -6 -18
		mu 0 4 4 6 7 5
		f 4 3 20 -7 -20
		mu 0 4 3 2 8 9
		f 4 4 21 -8 -21
		mu 0 4 2 5 10 8
		f 4 5 22 -9 -22
		mu 0 4 5 7 11 10
		f 4 6 24 -10 -24
		mu 0 4 9 8 12 13
		f 4 7 25 -11 -25
		mu 0 4 8 10 14 12
		f 4 8 26 -12 -26
		mu 0 4 10 11 15 14
		f 4 12 32 -1 -32
		mu 0 4 16 17 18 19
		f 4 13 33 -2 -33
		mu 0 4 17 20 21 18
		f 4 14 34 -3 -34
		mu 0 4 20 22 23 21
		f 4 -35 -31 35 -19
		mu 0 4 6 24 25 7
		f 4 -36 -29 -27 -23
		mu 0 4 7 25 26 11
		f 4 31 15 -37 29
		mu 0 4 27 0 3 28
		f 4 36 19 23 27
		mu 0 4 28 3 9 29;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_l_shoulder" -p "ctrl_l_clavicle";
	rename -uid "A966DE41-40AD-5BC1-E196-A0A03FAD3F45";
	setAttr ".t" -type "double3" 3.9696734265670752 -1.5158155911230692e-10 -4.011432963579864e-09 ;
	setAttr ".r" -type "double3" -0.82766212146448137 -14.017145624632795 3.4132886591964113 ;
	setAttr ".s" -type "double3" 1 1 0.99999999999999967 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".rpt" -type "double3" 3.7329573629958966e-17 1.1123067241635789e-18 9.3357350589447917e-18 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "offset_l_shoulder" -p "prnt_l_shoulder";
	rename -uid "0D737A35-4B21-CAD0-F079-5295B1AB0C9F";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_l_shoulder" -p "offset_l_shoulder";
	rename -uid "AD95638F-484C-5EC2-E371-1C80FC926FD3";
	setAttr ".rp" -type "double3" 4.0792985522841718e-07 -4.0863444850103292e-09 1.2574321885949757e-06 ;
	setAttr ".sp" -type "double3" 4.0792985522841718e-07 -4.0863444850103292e-09 1.2574321885949757e-06 ;
createNode mesh -n "ctrl_l_shoulderShape" -p "ctrl_l_shoulder";
	rename -uid "7D696F29-4775-2A29-4817-10BDFA3C7D0E";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 26 ".uvst[0].uvsp[0:25]" -type "float2" 0.375 0 0.48798609
		 0 0.48798609 0.094423816 0.375 0.094423816 0.375 0.65557623 0.48798609 0.65557623
		 0.48798609 0.75 0.375 0.75 0.375 0.87287432 0.48798609 0.87287432 0.48798609 1 0.375
		 1 0.625 0 0.75212574 0 0.75212574 0.094423816 0.625 0.094423816 0.24787429 0 0.24787429
		 0.094423808 0.125 0 0.125 0.094423808 0.875 0.094423808 0.875 0 0.625 0.65557623
		 0.625 0.75 0.625 0.87287432 0.625 1;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 17 ".pt[0:16]" -type "float3"  2.8897316 -12.039922 -62.59206 
		-4.5084009 -4.2013469 -62.59206 2.7421796 -8.4928255 -45.763313 -4.4647775 -0.85680789 
		-45.763313 4.7680111 -12.573826 -55.364773 -6.394464 -0.74680084 -55.364773 -0.36961567 
		-4.6636233 -43.122196 0.3302266 -7.8431721 -55.222488 -0.23024423 -9.2417488 -65.111084 
		4.2256136 -11.204994 -51.423355 5.7214518 -13.897558 -56.920864 9.1148672 -17.875311 
		-58.818325 11.592522 -20.1173 -56.916611 13.084086 -20.590302 -51.420631 12.082613 
		-18.480665 -46.216599 9.129632 -14.943679 -44.190636 5.2243681 -11.214257 -46.217281;
	setAttr -s 17 ".vt[0:16]"  -3.26297522 8.7930851 58.74832916 4.58871031 8.7930851 58.74832916
		 -3.16152692 5.35027504 50.68603897 4.48726273 5.35027504 50.68603897 -5.26053619 7.33298922 55.28217316
		 6.58627033 7.33298922 55.28217316 0.093560614 4.77331352 49.42811966 -0.5534842 7.30168009 55.21445084
		 0.093560614 9.34337425 59.94809723 5.10940456 15.78280544 51.52893829 3.52414441 16.89263153 54.16566849
		 -0.043197442 17.30713844 55.069396973 -2.70693755 16.89170074 54.16364288 -4.2921977 15.7822113 51.5276413
		 -3.22956347 14.73344803 49.031303406 -0.13196933 14.29086876 48.066371918 4.049148083 14.7335968 49.031627655;
	setAttr -s 28 ".ed[0:27]"  0 8 0 2 6 0 0 12 0 1 10 0 2 4 0 3 5 0 4 0 0
		 5 1 0 4 7 1 5 9 1 6 3 0 7 5 1 6 7 1 8 1 0 7 8 1 8 11 1 9 10 0 10 11 0 11 12 0 13 4 1
		 12 13 0 14 2 0 13 14 0 15 6 1 14 15 0 16 3 0 15 16 0 16 9 0;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 0 15 18 -3
		mu 0 4 0 1 2 3
		f 4 24 23 -2 -22
		mu 0 4 4 5 6 7
		f 4 8 14 -1 -7
		mu 0 4 8 9 10 11
		f 4 -8 9 16 -4
		mu 0 4 12 13 14 15
		f 4 6 2 20 19
		mu 0 4 16 0 3 17
		f 4 4 -20 22 21
		mu 0 4 18 16 17 19
		f 4 1 12 -9 -5
		mu 0 4 7 6 9 8
		f 4 27 -10 -6 -26
		mu 0 4 20 14 13 21
		f 4 -24 26 25 -11
		mu 0 4 6 5 22 23
		f 4 -13 10 5 -12
		mu 0 4 9 6 23 24
		f 4 -15 11 7 -14
		mu 0 4 10 9 24 25
		f 4 -16 13 3 17
		mu 0 4 2 1 12 15;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_l_elbow" -p "ctrl_l_shoulder";
	rename -uid "ED62ED72-4DDF-8F6C-5A19-4FBD3F8C1798";
	setAttr ".t" -type "double3" 10.564649377766768 7.4311112818747915e-11 2.767336582110147e-09 ;
	setAttr ".r" -type "double3" -0.18678659712930273 -2.040999722723154 1.9185657755564591 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1.0000000000000004 1.0000000000000007 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509422e-16 0 ;
	setAttr ".rpt" -type "double3" 2.2224098979249449e-17 3.743697346130012e-19 2.1702420995248097e-18 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".spt" -type "double3" 0 -2.9582283945787956e-31 0 ;
createNode transform -n "offset_l_elbow" -p "prnt_l_elbow";
	rename -uid "BDE5AD39-4561-200A-01F0-8A9BB04E11D0";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_l_elbow" -p "offset_l_elbow";
	rename -uid "CA167D0E-4CE2-F57A-FBD4-ED92A5AAB27D";
	setAttr ".rp" -type "double3" 5.8495729149399267e-08 2.4754488237022088e-08 -1.2276912428887954e-06 ;
	setAttr ".sp" -type "double3" 5.8495729149399267e-08 2.4754488237022088e-08 -1.2276912428887954e-06 ;
createNode mesh -n "ctrl_l_elbowShape" -p "ctrl_l_elbow";
	rename -uid "3EE081CE-478A-EBB0-8387-819E56FFC6A2";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 20 ".uvst[0].uvsp[0:19]" -type "float2" 0.625 0.11420364
		 0.75212574 0.11420364 0.75212574 0.16905998 0.625 0.16905998 0.48798609 0.16905998
		 0.48798609 0.11420364 0.375 0.11420364 0.375 0.16905998 0.24787429 0.11420363 0.24787429
		 0.16905996 0.125 0.11420363 0.125 0.16905996 0.375 0.58094001 0.48798609 0.58094001
		 0.48798609 0.63579637 0.375 0.63579637 0.625 0.63579637 0.625 0.58094001 0.875 0.16905996
		 0.875 0.11420363;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 16 ".pt[0:15]" -type "float3"  -5.061655 -12.30505 -50.971004 
		-3.5618572 -15.126524 -56.322456 0.021565272 -19.428518 -58.029362 2.7062166 -21.932608 
		-56.04287 4.3957214 -22.579008 -50.57106 3.3637674 -20.338488 -45.530098 0.30709961 
		-16.57132 -43.630993 -3.8323691 -12.50913 -45.780434 0.25231987 -17.64777 -48.79285 
		1.6100098 -20.272346 -53.957199 4.7662554 -24.119133 -55.72237 7.1615186 -26.346815 
		-53.920574 8.6285343 -26.817322 -48.757061 7.6105757 -24.603752 -43.768852 5.5138807 
		-21.877256 -41.819221 1.989964 -18.470207 -43.881039;
	setAttr -s 16 ".vt[0:15]"  5.035866261 16.75148773 51.10646439 3.45877957 17.99635887 53.63781357
		 -0.079188593 18.74145508 54.36859131 -2.72426939 18.58579826 53.36146927 -4.29326296 17.64562988 50.69993973
		 -3.24388218 16.45727921 48.31891632 -0.17252181 15.77295017 47.47400284 3.97872186 15.87826157 48.5776329
		 5.33907461 21.88483047 48.83440399 3.78124595 22.96338272 51.30428314 0.28626347 23.33157921 52.14858627
		 -2.3266151 22.95538139 51.28684616 -3.87661123 21.87701035 48.81736374 -2.074820995 21.40105057 46.30715179
		 0.33916581 21.069595337 45.35805893 3.81244016 21.15495682 46.42014694;
	setAttr -s 24 ".ed[0:23]"  0 8 1 1 9 0 0 1 0 2 10 1 1 2 0 3 11 0 2 3 0
		 3 4 0 4 5 0 5 6 0 6 7 0 7 0 0 8 9 0 9 10 0 10 11 0 12 4 1 11 12 0 13 5 0 12 13 0
		 14 6 1 13 14 0 15 7 0 14 15 0 15 8 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 -3 0 12 -2
		mu 0 4 0 1 2 3
		f 4 -4 -5 1 13
		mu 0 4 4 5 0 3
		f 4 -7 3 14 -6
		mu 0 4 6 5 4 7
		f 4 -8 5 16 15
		mu 0 4 8 6 7 9
		f 4 -9 -16 18 17
		mu 0 4 10 8 9 11
		f 4 20 19 -10 -18
		mu 0 4 12 13 14 15
		f 4 -11 -20 22 21
		mu 0 4 16 14 13 17
		f 4 23 -1 -12 -22
		mu 0 4 18 2 1 19;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_l_wrist" -p "ctrl_l_elbow";
	rename -uid "A7FAF13D-4072-BE32-00B2-F4932372C0CB";
	setAttr ".t" -type "double3" 6.2112901077982272 7.5116490805271496e-10 1.2082779221600504e-09 ;
	setAttr ".r" -type "double3" 179.99999995531095 24.833093125421065 0 ;
	setAttr ".s" -type "double3" 0.99999999999999944 0.99999999999999967 0.99999999999999989 ;
	setAttr ".rp" -type "double3" 0 -6.6613381477509363e-16 0 ;
	setAttr ".rpt" -type "double3" -2.1820499182956143e-25 1.3322676295501873e-15 -4.7152343059893713e-25 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".spt" -type "double3" 0 2.9582283945787934e-31 0 ;
createNode transform -n "offset_l_wrist" -p "prnt_l_wrist";
	rename -uid "F66D2B12-4167-EF42-A913-97BAB2B76F71";
	setAttr ".rp" -type "double3" 0 -6.6613381477509392e-16 0 ;
	setAttr ".sp" -type "double3" 0 -6.6613381477509392e-16 0 ;
createNode transform -n "ctrl_l_wrist" -p "offset_l_wrist";
	rename -uid "89EED426-4149-AA0B-4CDE-67B5DCE452BD";
	setAttr ".rp" -type "double3" -6.135631060999458e-07 -1.3174751911648741e-07 1.4052632693051237e-06 ;
	setAttr ".sp" -type "double3" -6.135631060999458e-07 -1.3174751911648741e-07 1.4052632693051237e-06 ;
createNode mesh -n "ctrl_l_wristShape" -p "ctrl_l_wrist";
	rename -uid "F69A1656-44F3-5953-F505-EC8BE994D273";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:11]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.49971739947795868 0.31833702325820923 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 23 ".uvst[0].uvsp[0:22]" -type "float2" 0.375 0.25 0.48798609
		 0.25 0.48798609 0.37712568 0.375 0.37712568 0.48798609 0.5 0.375 0.5 0.625 0.25 0.6478433
		 0.38988671 0.625 0.5 0.625 0.17429687 0.75212574 0.17429687 0.76485151 0.25506198
		 0.48798609 0.17429687 0.375 0.17429687 0.24787429 0.17429686 0.24787429 0.25 0.125
		 0.17429686 0.125 0.25 0.48798609 0.57570314 0.375 0.57570314 0.625 0.57570314 0.875
		 0.17429686 0.875 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 17 ".pt[0:16]" -type "float3"  8.20473 -26.808945 -48.343067 
		3.6179359 -30.748045 -48.513569 7.168551 -25.367643 -48.334969 2.0824687 -29.770773 
		-48.524731 2.3558805 -31.415071 -48.552143 8.8103113 -25.681072 -48.308403 6.3066959 
		-29.075512 -48.426353 6.1797376 -29.163696 -48.430653 4.7466288 -27.510328 -48.42625 
		-4.8134637 -27.398071 -48.615185 -2.3092885 -26.928738 -48.555721 1.2621135 -23.819393 
		-48.422123 3.28228 -20.841873 -48.322178 3.6274757 -18.218321 -48.26281 1.5009557 
		-19.48274 -48.330624 -1.0428646 -21.545881 -48.422752 -4.1413884 -25.120604 -48.556202;
	setAttr -s 17 ".vt[0:16]"  -1.32229066 29.927948 47.3331604 3.10811424 29.40312576 47.55666351
		 -1.52048838 28.71107864 43.99638367 3.41140103 28.14682388 44.24083328 4.14556742 29.095161438 45.37133026
		 -2.19324231 29.73748779 45.089889526 0.85202736 30.024265289 47.67131042 1.012449622 30.048431396 45.22124863
		 0.86389196 28.47628403 43.56776047 5.48928261 23.13330841 48.34658432 3.93238688 24.20908356 50.81010056
		 0.43947417 24.57627106 51.65210342 -2.17185044 24.20108032 50.79266357 -3.72093391 23.12548256 48.32953262
		 -1.92011809 22.65324402 45.8278389 0.49237117 22.3228302 44.88113403 3.96361232 22.40717316 45.94087982;
	setAttr -s 28 ".ed[0:27]"  0 6 0 2 8 0 0 5 0 1 4 0 2 14 0 3 16 0 4 3 0
		 5 2 0 4 7 1 5 13 1 6 1 0 7 5 1 6 7 1 8 3 0 7 8 1 8 15 1 10 1 0 9 10 0 10 11 0 11 12 0
		 12 13 0 13 14 0 14 15 0 15 16 0 16 9 0 11 6 1 12 0 0 9 4 1;
	setAttr -s 12 -ch 48 ".fc[0:11]" -type "polyFaces" 
		f 4 0 12 11 -3
		mu 0 4 0 1 2 3
		f 4 -12 14 -2 -8
		mu 0 4 3 2 4 5
		f 4 10 3 8 -13
		mu 0 4 1 6 7 2
		f 4 -15 -9 6 -14
		mu 0 4 4 2 7 8
		f 4 -17 -18 27 -4
		mu 0 4 6 9 10 11
		f 4 -19 16 -11 -26
		mu 0 4 12 9 6 1
		f 4 -20 25 -1 -27
		mu 0 4 13 12 1 0
		f 4 -21 26 2 9
		mu 0 4 14 13 0 15
		f 4 -22 -10 7 4
		mu 0 4 16 14 15 17
		f 4 -23 -5 1 15
		mu 0 4 18 19 5 4
		f 4 -24 -16 13 5
		mu 0 4 20 18 4 8
		f 4 -25 -6 -7 -28
		mu 0 4 10 21 22 11;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode joint -n "ctrl_j_l_clavicle" -p "grp_l_arm";
	rename -uid "87EF1DBD-4A8C-A30E-B96D-4F8C09F08A0A";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -179.99999999966369 8.7424967398755804 90.000000002213568 ;
createNode joint -n "ctrl_j_l_shoulder" -p "ctrl_j_l_clavicle";
	rename -uid "3E0B5A69-49C6-4508-437B-26A8DDAD4B36";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.82766214234402258 -14.017145625753072 3.4132886617115137 ;
createNode joint -n "ctrl_j_l_elbow" -p "ctrl_j_l_shoulder";
	rename -uid "88269A33-4C2B-CE9D-76FE-BCA070F6A09A";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -0.18678661638172545 -2.0409997214780704 1.9185657772405322 ;
createNode joint -n "ctrl_j_l_wrist" -p "ctrl_j_l_elbow";
	rename -uid "968C73E5-4D5E-8834-1AA8-5183F8C7224B";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 179.99999999999889 24.833093124436282 0 ;
createNode parentConstraint -n "ctrl_j_l_wrist_parentConstraint1" -p "ctrl_j_l_wrist";
	rename -uid "AD4ABEFC-496D-B79D-423C-9D9DE92D2959";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_wristW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 6.133144765385623e-07 1.3156990763540932e-07 
		-1.4011775348876654e-06 ;
	setAttr ".tg[0].tor" -type "double3" 6.3064038224058613e-10 5.2412360595837293e-11 
		5.7784527886647275e-22 ;
	setAttr ".lr" -type "double3" -6.3058949336568262e-10 -5.2425082814563147e-11 -1.0295651838829762e-24 ;
	setAttr ".rst" -type "double3" 6.211290107798237 4.5537262849393301e-10 1.3094023643134278e-09 ;
	setAttr ".rsrr" -type "double3" -6.3064038224058603e-10 -5.240918004115583e-11 -1.0243779612015075e-24 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_elbow_parentConstraint1" -p "ctrl_j_l_elbow";
	rename -uid "7EEF04B8-4B89-6F3F-1E49-A4A7F591C2D6";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_elbowW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -6.043729072757742e-08 -2.4576876533899394e-08 
		1.2240876756663965e-06 ;
	setAttr ".tg[0].tor" -type "double3" -3.9983551642320332e-08 9.3237920730169449e-10 
		2.7285197295351553e-09 ;
	setAttr ".lr" -type "double3" 3.9983580062337966e-08 -9.3236544633518514e-10 -2.7285376791065095e-09 ;
	setAttr ".rst" -type "double3" 10.564649375950255 1.2385703573869478e-10 -1.0881393563977326e-09 ;
	setAttr ".rsrr" -type "double3" 3.9983551567798274e-08 -9.3237890700789804e-10 -2.7285196949178663e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_shoulder_parentConstraint1" -p "ctrl_j_l_shoulder";
	rename -uid "C5D1534C-4CB5-B7BC-E7CE-DAA2C9052737";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_shoulderW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -4.079298516757035e-07 4.086343707854212e-09 
		-1.2574321957004031e-06 ;
	setAttr ".tg[0].tor" -type "double3" -2.0793204423553937e-08 -1.0005086764253189e-09 
		3.0133260859288541e-10 ;
	setAttr ".lr" -type "double3" 2.0793227731053576e-08 1.0005259552160291e-09 -3.0135194643227898e-10 ;
	setAttr ".rst" -type "double3" 3.9696734265670797 5.5869031005996956e-16 -4.0028211856224516e-09 ;
	setAttr ".rsrr" -type "double3" 2.0793204324158968e-08 1.0005123074061914e-09 -3.0133302461673529e-10 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_clavicle_parentConstraint1" -p "ctrl_j_l_clavicle";
	rename -uid "2656D184-48F7-C6EC-E0F5-7CB9088F39EA";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_clavicleW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.6416809067720806e-07 -5.712779138633542e-10 
		-7.9965064969655941e-07 ;
	setAttr ".tg[0].tor" -type "double3" -1.2258089392884676e-13 1.2443920191226008e-10 
		-2.1878399542851241e-09 ;
	setAttr ".lr" -type "double3" 1.4869092898290418e-13 -1.2442170886151489e-10 2.187833593175761e-09 ;
	setAttr ".rst" -type "double3" 7.4483563759999999e-09 3.5516707490000003 55.736206870000004 ;
	setAttr ".rsrr" -type "double3" 1.2324649153090898e-13 -1.2443602135758099e-10 2.1878463153944869e-09 ;
	setAttr -k on ".w0";
createNode transform -n "prnt_tail_01" -p "ctrl_spine_01";
	rename -uid "41A7A591-4B5B-1935-E193-84939B85BE97";
	setAttr ".t" -type "double3" -1.8890921882418255 -8.5008000433707736 0.00025128030125407566 ;
	setAttr ".r" -type "double3" 6.4524613686227711e-05 -6.2132263093586502e-05 -92.161079500001279 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1.0000000000000004 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005025e-15 0 ;
	setAttr ".rpt" -type "double3" -3.5501868550665767e-15 3.6866829948123328e-15 -4.0009487541722756e-21 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 -1.5777218104420243e-30 0 ;
createNode transform -n "offset_tail_01" -p "prnt_tail_01";
	rename -uid "C0D9C762-4334-67DC-D1A0-24970DA7AAAE";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_tail_01" -p "offset_tail_01";
	rename -uid "F3284019-4BF3-2E4C-1412-F5B493710F55";
	setAttr ".t" -type "double3" -7.6795458880951628e-11 -2.7829116788780084e-10 3.0201129140941529e-16 ;
	setAttr ".r" -type "double3" 1.9083328088781101e-14 7.0622500768802538e-31 1.176100896151986e-46 ;
	setAttr ".rp" -type "double3" 1.1907679464684406e-07 -2.6972171340844397e-07 3.3395507903098351e-13 ;
	setAttr ".sp" -type "double3" 1.1907679464684406e-07 -2.6972171340844397e-07 3.3395507903098351e-13 ;
createNode mesh -n "ctrl_tail_0Shape1" -p "ctrl_tail_01";
	rename -uid "262F04A9-414B-9FA3-5DE0-6594FCF3D932";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.60890108346939087 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 18 ".uvst[0].uvsp[0:17]" -type "float2" 0.75 0 0.875 0 0.875
		 0.25 0.75 0.25 0.625 0 0.625 0.25 0.60890108 0.25 0.625 0.375 0.60890108 0.375 0.60890108
		 0.5 0.625 0.5 0.60890108 0.75 0.625 0.75 0.60890108 0.875 0.625 0.875 0.60890108
		 1 0.625 1 0.60890108 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  6.6775365 4.4680991 -35.138683 
		6.6775365 1.6728269 -32.34341 6.6775365 -3.3594215 -27.311155 6.6775365 -4.6522117 
		-26.018364 6.6775365 -1.2471418 -29.423437 6.6775365 3.1303027 -33.800888 15.563452 
		1.1863527 -31.856934 15.563452 -2.5421498 -28.128428 15.563452 -3.1972933 -27.473284 
		15.563452 -0.65447575 -30.016104 15.563452 2.5553174 -33.225899 15.563452 3.7291703 
		-34.399754;
	setAttr -s 12 ".vt[0:11]"  -6.45266724 -1.39763749 33.74104309 -6.45266724 1.39763749 33.74104309
		 -6.45266724 3.24486566 30.55602074 -6.45266724 1.70253682 27.7209034 -6.45266724 -1.70253682 27.7209034
		 -6.45266724 -3.24486566 30.55602074 -9.96122456 1.27141011 33.12834167 -9.96122456 2.54873633 30.67716408
		 -9.96122456 1.27141011 28.74469566 -9.96122456 -1.27141011 28.74469566 -9.96122456 -2.54873633 30.67716408
		 -9.96122456 -1.27141011 33.12834167;
	setAttr -s 19 ".ed[0:18]"  0 1 0 1 2 0 2 3 0 3 4 0 4 5 0 5 0 0 5 2 1
		 6 1 0 7 2 1 6 7 0 8 3 0 7 8 0 9 4 0 8 9 0 10 5 1 9 10 0 11 0 0 10 11 0 11 6 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 -5 -4 -3 -7
		mu 0 4 0 1 2 3
		f 4 -6 6 -2 -1
		mu 0 4 4 0 3 5
		f 4 7 1 -9 -10
		mu 0 4 6 5 7 8
		f 4 -12 8 2 -11
		mu 0 4 9 8 7 10
		f 4 -14 10 3 -13
		mu 0 4 11 9 10 12
		f 4 -16 12 4 -15
		mu 0 4 13 11 12 14
		f 4 -18 14 5 -17
		mu 0 4 15 13 14 16
		f 4 -19 16 0 -8
		mu 0 4 6 17 4 5;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_tail_02" -p "ctrl_tail_01";
	rename -uid "E7E2E1D0-4629-F96F-D9D8-778609EB7558";
	setAttr ".t" -type "double3" 6.6487777639999992 0 1.3129403705729181e-14 ;
	setAttr ".r" -type "double3" -6.2180308447471819e-05 0 0.22160629070008653 ;
	setAttr ".s" -type "double3" 0.99999999999999989 0.99999999999999989 1 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005001e-15 0 ;
	setAttr ".rpt" -type "double3" 1.374100752301439e-17 2.6573490835210161e-20 3.8555864716507441e-21 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 7.8886090522101172e-31 0 ;
createNode transform -n "offset_tail_02" -p "prnt_tail_02";
	rename -uid "2FF18A3C-416B-1D83-BE8B-45AA64911B7D";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_tail_02" -p "offset_tail_02";
	rename -uid "31324F0A-431C-BE92-72B0-C89C97BB8DB5";
	setAttr ".rp" -type "double3" -1.6107142108978678e-07 -2.6910074524266747e-07 4.4947743305101533e-08 ;
	setAttr ".sp" -type "double3" -1.6107142108978678e-07 -2.6910074524266747e-07 4.4947743305101533e-08 ;
createNode mesh -n "ctrl_tail_0Shape2" -p "ctrl_tail_02";
	rename -uid "89759BF3-45E5-6B30-F7DF-048E431119DC";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:5]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.56526374816894531 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 14 ".uvst[0].uvsp[0:13]" -type "float2" 0.56526375 0.25 0.60330814
		 0.25 0.60330814 0.375 0.56526375 0.375 0.56526375 0.5 0.60330814 0.5 0.56526375 0.75
		 0.60330814 0.75 0.56526375 0.875 0.60330814 0.875 0.56526375 1 0.60330814 1 0.56526375
		 0 0.60330814 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  29.030415 0.82076228 -31.529562 
		29.02264 -2.1511145 -28.557671 29.016512 -2.7736802 -27.935093 29.016512 -0.36529741 
		-30.343475 29.02264 2.1812525 -32.890038 29.030415 3.2291443 -33.937943 11.138227 
		1.1681312 -31.838694 11.128841 -2.5181985 -28.152344 11.121442 -3.1715117 -27.499018 
		11.121442 -0.63618308 -30.034346 11.128841 2.5366397 -33.207184 11.138227 3.7034607 
		-34.374023;
	setAttr -s 12 ".vt[0:11]"  -19.144907 1.20419121 32.7337532 -19.144907 2.16618347 30.72385406
		 -19.144907 1.20419121 29.13928413 -19.144907 -1.20419121 29.13928413 -19.144907 -2.16618347 30.72385406
		 -19.144907 -1.20419121 32.7337532 -11.13828945 1.26766443 33.10635757 -11.13828945 2.52741909 30.67976379
		 -11.13828945 1.26766443 28.76668167 -11.13828945 -1.26766443 28.76668167 -11.13828945 -2.52741909 30.67976379
		 -11.13828945 -1.26766443 33.10635757;
	setAttr -s 18 ".ed[0:17]"  0 6 0 1 7 1 0 1 0 2 8 0 1 2 0 3 9 0 2 3 0
		 4 10 1 3 4 0 5 11 0 4 5 0 5 0 0 6 7 0 7 8 0 8 9 0 9 10 0 10 11 0 11 6 0;
	setAttr -s 6 -ch 24 ".fc[0:5]" -type "polyFaces" 
		f 4 0 12 -2 -3
		mu 0 4 0 1 2 3
		f 4 -5 1 13 -4
		mu 0 4 4 3 2 5
		f 4 -7 3 14 -6
		mu 0 4 6 4 5 7
		f 4 -9 5 15 -8
		mu 0 4 8 6 7 9
		f 4 -11 7 16 -10
		mu 0 4 10 8 9 11
		f 4 -12 9 17 -1
		mu 0 4 0 12 13 1;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_tail_03" -p "ctrl_tail_02";
	rename -uid "8D91E979-48E0-6454-4D7C-37B0CE6B27CC";
	setAttr ".t" -type "double3" 12.267247986236523 4.3917900427459244e-09 9.3604442863317603e-09 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_tail_03" -p "prnt_tail_03";
	rename -uid "1B10EE1B-4AB1-1B17-2A9C-32B0ABC1FA88";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_tail_03" -p "offset_tail_03";
	rename -uid "AF8D2CC2-4E1C-43E2-E256-30BE918BA20B";
	setAttr ".rp" -type "double3" 2.120229858348921e-07 2.8405021978983314e-07 8.7768196266324594e-08 ;
	setAttr ".sp" -type "double3" 2.120229858348921e-07 2.8405021978983314e-07 8.7768196266324594e-08 ;
createNode mesh -n "ctrl_tail_0Shape3" -p "ctrl_tail_03";
	rename -uid "0C16026B-4ADE-B9B0-BCF9-F48595F0C65B";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:5]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.49638530611991882 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 14 ".uvst[0].uvsp[0:13]" -type "float2" 0.49638098 0.26341233
		 0.56291771 0.25 0.56291771 0.375 0.49638528 0.3640613 0.49638537 0.486341 0.56291771
		 0.5 0.49638537 0.763659 0.56291771 0.75 0.49638528 0.8859387 0.56291771 0.875 0.49638098
		 1.0035600662 0.56291771 1 0.49638101 -0.015372765 0.56291771 0;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  20.965218 0.78046781 -31.49662 
		20.957615 -2.1152706 -28.600868 20.951622 -2.7345603 -27.981567 20.951622 -0.33970529 
		-30.376419 20.957615 2.1401014 -32.856239 20.965218 3.1753194 -33.891472 44.077663 
		0.87291175 -31.349335 44.06913 -2.0657732 -28.339153 44.062386 -2.8756671 -27.834282 
		44.062386 -0.48081416 -30.523705 44.06913 2.1895988 -33.117954 44.077663 3.2677643 
		-34.038757;
	setAttr -s 12 ".vt[0:11]"  -21.44630051 1.19742656 32.69404602 -21.44630051 2.12768602 30.72855377
		 -21.44630051 1.19742656 29.17899323 -21.44630051 -1.19742656 29.17899323 -21.44630051 -2.12768602 30.72855377
		 -21.44630051 -1.19742656 32.69404602 -32.71432114 1.19742656 32.69404602 -32.71432114 2.12768602 30.72855377
		 -32.71432114 1.19742656 29.17899323 -32.71432114 -1.19742656 29.17899323 -32.71432114 -2.12768602 30.72855377
		 -32.71432114 -1.19742656 32.69404602;
	setAttr -s 18 ".ed[0:17]"  0 1 0 1 2 0 2 3 0 3 4 0 4 5 0 5 0 0 6 0 0
		 7 1 1 6 7 0 8 2 0 7 8 0 9 3 0 8 9 0 10 4 1 9 10 0 11 5 0 10 11 0 11 6 0;
	setAttr -s 6 -ch 24 ".fc[0:5]" -type "polyFaces" 
		f 4 6 0 -8 -9
		mu 0 4 0 1 2 3
		f 4 -11 7 1 -10
		mu 0 4 4 3 2 5
		f 4 -13 9 2 -12
		mu 0 4 6 4 5 7
		f 4 -15 11 3 -14
		mu 0 4 8 6 7 9
		f 4 -17 13 4 -16
		mu 0 4 10 8 9 11
		f 4 -18 15 5 -7
		mu 0 4 0 12 13 1;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_tail_04" -p "ctrl_tail_03";
	rename -uid "E2E414F3-4A8D-2337-2550-02BDF826114F";
	setAttr ".t" -type "double3" 14.092836333001408 -0.055406428948625575 9.9617123998674107e-09 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_tail_04" -p "prnt_tail_04";
	rename -uid "1D266976-4635-EA19-53B2-E5B7B0C2F9F8";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_tail_04" -p "offset_tail_04";
	rename -uid "F83F6A1E-4F0C-4A52-E3C6-818906E88E60";
	setAttr ".rp" -type "double3" -1.8160900765451515e-06 3.8068911578648112e-07 1.3696185874323421e-07 ;
	setAttr ".sp" -type "double3" -1.8160900765451515e-06 3.8068911578648112e-07 1.3696185874323421e-07 ;
createNode mesh -n "ctrl_tail_0Shape4" -p "ctrl_tail_04";
	rename -uid "2D138E57-4D9B-214E-6845-0C9E2859559D";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:5]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.43142148852348328 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 14 ".uvst[0].uvsp[0:13]" -type "float2" 0.43142158 0.36381444
		 0.43142793 0.26920995 0.48864049 0.27972755 0.48864108 0.37778154 0.4314214 0.47648335
		 0.48864567 0.47044963 0.4314214 0.7735163 0.48864567 0.77955031 0.43142176 0.8669948
		 0.48864108 0.87221819 0.43141434 1.20413268 0.48863935 1.10379064 0.4313637 -0.022211321
		 0.48857433 -0.015635416;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  34.860924 1.0681224 -31.307703 
		34.851536 -2.2979679 -28.118176 34.844181 -2.952306 -27.683397 34.844181 -0.5388422 
		-30.565336 34.851536 2.0633211 -33.325974 34.860924 3.4815838 -34.189644 58.191002 
		1.6484721 -32.0825 58.178169 -3.0000892 -27.282106 58.168129 -3.9610572 -26.784023 
		58.168129 -1.2683079 -29.789841 58.178169 2.9851308 -33.963127 58.191002 4.3409448 
		-35.087994;
	setAttr -s 12 ".vt[0:11]"  -35.42835236 1.20673203 32.74867249 -35.42835236 2.18064451 30.72208786
		 -35.42835236 1.20673203 29.12436676 -35.42835236 -1.20673203 29.12436676 -35.42835236 -2.18064451 30.72208786
		 -35.42835236 -1.20673203 32.74867249 -45.57728958 1.34623599 33.58524704 -45.57728958 2.99260998 30.62261772
		 -45.57728958 1.3463757 28.28693199 -45.57728958 -1.3463757 28.28693199 -45.57728958 -2.99260998 30.62261772
		 -45.57728958 -1.34623599 33.58524704;
	setAttr -s 18 ".ed[0:17]"  0 1 0 1 2 0 2 3 0 3 4 0 4 5 0 5 0 0 6 0 0
		 7 1 1 6 7 0 8 2 0 7 8 0 9 3 0 8 9 0 10 4 1 9 10 0 11 5 0 10 11 0 11 6 0;
	setAttr -s 6 -ch 24 ".fc[0:5]" -type "polyFaces" 
		f 4 -9 6 0 -8
		mu 0 4 0 1 2 3
		f 4 -11 7 1 -10
		mu 0 4 4 0 3 5
		f 4 -13 9 2 -12
		mu 0 4 6 4 5 7
		f 4 -15 11 3 -14
		mu 0 4 8 6 7 9
		f 4 -17 13 4 -16
		mu 0 4 10 8 9 11
		f 4 -18 15 5 -7
		mu 0 4 1 12 13 2;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_tail_05" -p "ctrl_tail_04";
	rename -uid "FE6E98C2-417C-D465-3374-C19E731E352D";
	setAttr ".t" -type "double3" 14.702116910693213 -0.056864534670687306 1.184805631301e-08 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "offset_tail_05" -p "prnt_tail_05";
	rename -uid "926FFD43-4894-94D2-377A-9593F2E724A0";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_tail_05" -p "offset_tail_05";
	rename -uid "6EDD159A-416E-208B-524A-D5B5BB0665EF";
	setAttr ".rp" -type "double3" -1.4995993069533142e-07 3.7424489462978272e-07 1.8828230707867985e-07 ;
	setAttr ".sp" -type "double3" -1.4995993069533142e-07 3.7424489462978272e-07 1.8828230707867985e-07 ;
createNode mesh -n "ctrl_tail_0Shape5" -p "ctrl_tail_05";
	rename -uid "AF90C4FA-4875-1B06-7626-05B4F561251D";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:7]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.41453093290328979 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 18 ".uvst[0].uvsp[0:17]" -type "float2" 0.375 0 0.41381261
		 0.00062999013 0.40777802 0.26157564 0.375 0.25 0.42144015 0.36371148 0.375 0.375
		 0.40781558 0.48944032 0.375 0.5 0.40781558 0.76055968 0.375 0.75 0.42144001 0.88628829
		 0.375 0.875 0.38823986 0.9851076 0.375 1 0.125 0 0.25 0 0.25 0.25 0.125 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 12 ".pt[0:11]" -type "float3"  59.447678 5.2056465 -35.93343 
		59.447678 1.7355186 -32.463299 64.866501 -3.9822295 -26.756031 59.358105 -4.6693525 
		-26.058256 59.358105 -1.1548753 -29.572733 64.866501 3.8372047 -34.575466 49.202721 
		3.2091377 -34.197472 49.388168 4.5989466 -35.275394 49.388168 1.8530725 -32.141262 
		49.202721 -3.0755208 -27.024115 49.32769 -4.1010218 -26.594631 49.32769 -1.3498861 
		-29.734776;
	setAttr -s 12 ".vt[0:11]"  -56.68656921 -1.73506403 34.19836426 -56.68656921 1.73506403 34.19836426
		 -59.40282059 3.90971708 30.6657486 -56.65412521 1.75723863 27.81549454 -56.65412521 -1.75723863 27.81549454
		 -59.40282059 -3.90971708 30.6657486 -49.2491951 -3.14232922 30.61080742 -49.32941055 -1.37293696 33.70832825
		 -49.32941055 1.37293696 33.70832825 -49.2491951 3.14232922 30.61080742 -49.31261826 1.37556791 28.16470337
		 -49.31261826 -1.37556791 28.16470337;
	setAttr -s 19 ".ed[0:18]"  0 7 0 1 8 0 2 9 1 3 10 0 4 11 0 5 6 1 0 1 0
		 1 2 0 2 3 0 3 4 0 4 5 0 5 0 0 5 2 1 6 7 0 7 8 0 8 9 0 9 10 0 10 11 0 11 6 0;
	setAttr -s 8 -ch 32 ".fc[0:7]" -type "polyFaces" 
		f 4 0 14 -2 -7
		mu 0 4 0 1 2 3
		f 4 1 15 -3 -8
		mu 0 4 3 2 4 5
		f 4 2 16 -4 -9
		mu 0 4 5 4 6 7
		f 4 3 17 -5 -10
		mu 0 4 7 6 8 9
		f 4 4 18 -6 -11
		mu 0 4 9 8 10 11
		f 4 5 13 -1 -12
		mu 0 4 11 10 12 13
		f 4 10 12 8 9
		mu 0 4 14 15 16 17
		f 4 11 6 7 -13
		mu 0 4 15 0 3 16;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode transform -n "prnt_pelvis_low" -p "ctrl_pelvis";
	rename -uid "8675F2A0-4E8E-833F-D39F-219D27CD1F44";
	setAttr ".t" -type "double3" 3.5527136788005009e-15 0 0 ;
	setAttr ".s" -type "double3" 0.99999999999999978 1.0000000000000002 0.99999999999999967 ;
	setAttr ".rp" -type "double3" 0 -5.329070518200753e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".spt" -type "double3" 0 -1.5777218104420243e-30 0 ;
createNode transform -n "offset_pelvis_low" -p "prnt_pelvis_low";
	rename -uid "DA9F55C8-43B4-D3AA-BD03-C692AE0E84F1";
	setAttr ".rp" -type "double3" 0 -5.3290705182007514e-15 0 ;
	setAttr ".sp" -type "double3" 0 -5.3290705182007514e-15 0 ;
createNode transform -n "ctrl_pelvis_low" -p "offset_pelvis_low";
	rename -uid "1117BC94-41FA-C951-375C-77A204E55D1C";
	setAttr ".t" -type "double3" 1.4210854715202004e-14 -1.7763568394002505e-15 -2.7105054312137611e-20 ;
	setAttr ".r" -type "double3" -1.1768052321415258e-13 6.3324843707938619e-12 -4.4527765540495735e-14 ;
	setAttr ".s" -type "double3" 1 1 0.99999999999999978 ;
createNode mesh -n "ctrl_pelvis_lowShape" -p "ctrl_pelvis_low";
	rename -uid "8051783D-4627-44D9-2D9D-51BE6D1C961E";
	setAttr -k off ".v";
	setAttr ".iog[0].og[0].gcl" -type "componentList" 1 "f[0:20]";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 40 ".uvst[0].uvsp[0:39]" -type "float2" 0.375 0.375 0.45833334
		 0.375 0.45833334 0.5 0.375 0.5 0.54166669 0.375 0.54166669 0.5 0.625 0.375 0.625
		 0.5 0.45833334 0.58333331 0.375 0.58333331 0.54166669 0.58333331 0.625 0.58333331
		 0.45833334 0.66666663 0.375 0.66666663 0.54166669 0.66666663 0.625 0.66666663 0.45833334
		 0.74999994 0.375 0.74999994 0.54166669 0.74999994 0.625 0.74999994 0.45833334 0.87499994
		 0.375 0.87499994 0.54166669 0.87499994 0.625 0.87499994 0.75 0 0.875 0 0.875 0.083333336
		 0.75 0.083333336 0.875 0.16666667 0.75 0.16666667 0.875 0.25 0.75 0.25 0.125 0 0.25
		 0 0.25 0.083333336 0.125 0.083333336 0.25 0.16666667 0.125 0.16666667 0.25 0.25 0.125
		 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 28 ".vt[0:27]"  0.96523142 -7.95595074 9.33680153 1.46453404 -3.41644287 12.50045967
		 2.20914865 3.35334873 12.50045204 2.70997763 7.90672445 9.14444351 -3.2265985 -6.62761879 8.74404526
		 -2.78128672 -2.57898998 11.56560421 -2.11719275 3.45875168 11.56559753 -1.67052174 7.51974726 8.57249069
		 -3.4453826 -8.61673832 3.85520935 -2.78128672 -2.57899833 3.85520363 -2.11719275 3.4587431 3.855196
		 -1.4530983 9.49648285 3.85519028 -3.4453826 -8.6167469 -3.85519218 -2.78128672 -2.57900667 -3.85519791
		 -2.11719275 3.45873451 -3.85520554 -1.4530983 9.49647617 -3.85521126 -3.2265985 -6.62763786 -8.74403191
		 -2.78128672 -2.57901478 -11.56559753 -2.11719227 3.45872593 -11.56560516 -1.67052174 7.51972866 -8.57250786
		 0.96523142 -7.95597076 -9.33678627 1.46453404 -3.41647053 -12.50045204 2.20914912 3.35332203 -12.50045967
		 2.7099781 7.9067049 -9.14446068 2.95376205 10.12312412 -3.85521126 2.95376205 10.12313271 3.85519028
		 0.71992111 -10.18625355 -3.85518837 0.71992111 -10.18624496 3.85521317;
	setAttr -s 48 ".ed[0:47]"  0 1 0 1 2 0 2 3 0 4 5 0 5 6 0 6 7 0 8 9 1
		 9 10 1 10 11 1 12 13 1 13 14 1 14 15 1 16 17 0 17 18 0 18 19 0 20 21 0 21 22 0 22 23 0
		 0 4 0 1 5 1 2 6 1 3 7 0 4 8 0 5 9 1 6 10 1 7 11 0 8 12 0 9 13 1 10 14 1 11 15 0 12 16 0
		 13 17 1 14 18 1 15 19 0 16 20 0 17 21 1 18 22 1 19 23 0 15 24 1 11 25 1 23 24 0 24 25 0
		 25 3 0 12 26 1 8 27 1 20 26 0 26 27 0 27 0 0;
	setAttr -s 21 -ch 84 ".fc[0:20]" -type "polyFaces" 
		f 4 0 19 -4 -19
		mu 0 4 0 1 2 3
		f 4 1 20 -5 -20
		mu 0 4 1 4 5 2
		f 4 2 21 -6 -21
		mu 0 4 4 6 7 5
		f 4 3 23 -7 -23
		mu 0 4 3 2 8 9
		f 4 4 24 -8 -24
		mu 0 4 2 5 10 8
		f 4 5 25 -9 -25
		mu 0 4 5 7 11 10
		f 4 6 27 -10 -27
		mu 0 4 9 8 12 13
		f 4 7 28 -11 -28
		mu 0 4 8 10 14 12
		f 4 8 29 -12 -29
		mu 0 4 10 11 15 14
		f 4 9 31 -13 -31
		mu 0 4 13 12 16 17
		f 4 10 32 -14 -32
		mu 0 4 12 14 18 16
		f 4 11 33 -15 -33
		mu 0 4 14 15 19 18
		f 4 12 35 -16 -35
		mu 0 4 17 16 20 21
		f 4 13 36 -17 -36
		mu 0 4 16 18 22 20
		f 4 14 37 -18 -37
		mu 0 4 18 19 23 22
		f 4 -38 -34 38 -41
		mu 0 4 24 25 26 27
		f 4 -39 -30 39 -42
		mu 0 4 27 26 28 29
		f 4 -40 -26 -22 -43
		mu 0 4 29 28 30 31
		f 4 34 45 -44 30
		mu 0 4 32 33 34 35
		f 4 43 46 -45 26
		mu 0 4 35 34 36 37
		f 4 44 47 18 22
		mu 0 4 37 36 38 39;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode joint -n "ik_j_pelvis" -p "ctrl_cog";
	rename -uid "AF97C501-4BA9-4B69-5246-BC9CF7F14850";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -89.999937157695356 -79.522222998277272 0 ;
	setAttr ".bps" -type "matrix" 0.17807765569036305 -4.2108129205686851e-09 0.98401643713091735 0
		 0.98401643713032627 1.0967970427433471e-06 -0.17807765569025152 0 -1.0785164665794156e-06 0.9999999999993987 1.9945855522784939e-07 0
		 0.78062339412385251 -0.00024205536575423349 23.815655133202849 1;
createNode parentConstraint -n "ik_j_pelvis_parentConstraint1" -p "ik_j_pelvis";
	rename -uid "E38F801B-4C66-56D1-D4C3-7A937656E0F9";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_pelvisW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -3.5527136788005009e-15 -5.3290705182007514e-15 
		2.7105054312137611e-20 ;
	setAttr ".tg[0].tor" -type "double3" 4.9992467372110134e-09 -2.2263873670604687e-14 
		9.5416640443905535e-15 ;
	setAttr ".lr" -type "double3" -4.999236905832678e-09 2.153858171997024e-14 -0.2199683417228952 ;
	setAttr ".rst" -type "double3" 0.78062339410000103 -0.00024205536579999996 23.81565513 ;
	setAttr ".rsrr" -type "double3" -4.999236905832678e-09 2.1538581719970237e-14 -0.2199683417228952 ;
	setAttr -k on ".w0";
createNode joint -n "ik_j_spine_03" -p "ctrl_cog";
	rename -uid "14600C8E-4EA7-F285-85A6-24B9D46ED965";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 90.068045576746783 -88.301379863058841 179.93183215154534 ;
	setAttr ".bps" -type "matrix" -0.029642150543423673 3.5266866018734973e-05 0.99956057428622569 0
		 0.99956057490484651 -1.611236140286465e-06 0.029642150618617087 0 2.6559138759374439e-06 0.99999999937682604 -3.5203608368616912e-05 0
		 1.396661238762509 -0.0002420054053424119 54.564941560437511 1;
createNode parentConstraint -n "ik_j_spine_03_parentConstraint1" -p "ik_j_spine_03";
	rename -uid "24D6B431-45FD-062E-8525-E79CE788396E";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_spine_03W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 0.0035238188186070829 -0.00043648430398546267 
		-7.5004262463634203e-08 ;
	setAttr ".tg[0].tor" -type "double3" -1.3116293522839049e-06 -1.6231599936757366e-07 
		-0.036486503040840425 ;
	setAttr ".lr" -type "double3" -6.3611093678827246e-14 1.6231602686391923e-07 -3.4986101586202172e-14 ;
	setAttr ".rst" -type "double3" 1.3966612387625095 -0.0002420054053424119 54.564941560437511 ;
	setAttr ".rsrr" -type "double3" -6.361109353916684e-15 1.6231600460003647e-07 6.361109353916684e-15 ;
	setAttr -k on ".w0";
createNode transform -n "crv_spine" -p "ctrl_cog";
	rename -uid "502AA613-483E-9B6B-D3C3-359660B11460";
	setAttr -l on ".tx";
	setAttr -l on ".ty";
	setAttr -l on ".tz";
	setAttr -l on ".rx";
	setAttr -l on ".ry";
	setAttr -l on ".rz";
	setAttr -l on ".sx";
	setAttr -l on ".sy";
	setAttr -l on ".sz";
	setAttr ".it" no;
createNode nurbsCurve -n "crv_spineShape" -p "crv_spine";
	rename -uid "04A0D250-4A49-720D-B306-BFA3048DC13E";
	setAttr -k off ".v";
	setAttr -s 4 ".iog[0].og";
	setAttr ".tw" yes;
createNode nurbsCurve -n "crv_spineShapeOrig" -p "crv_spine";
	rename -uid "20651945-4907-62C3-AC3C-53B94F9809ED";
	setAttr -k off ".v";
	setAttr ".io" yes;
	setAttr ".cc" -type "nurbsCurve" 
		3 2 0 no 3
		7 0 0 0 15.48916862399965 30.978337247999299 30.978337247999299 30.978337247999299
		
		5
		0.78062339412385251 -0.00024205536575423349 23.815655133202849
		1.8435277689153491 -0.00024205536575423343 28.85638809640022
		3.7225605641469213 -0.00024205536575269636 39.120056596272207
		2.175729317740235 -0.0002420553657429445 49.485623526209146
		1.3971997365712678 -0.0002420553657429445 54.561430697003225
		;
createNode ikHandle -n "ik_spine_hndl" -p "ctrl_cog";
	rename -uid "1563D963-4550-4793-C186-AC8BDC38CBD1";
	setAttr ".t" -type "double3" 1.3967124895085867 -0.000242091434500254 54.564607419109109 ;
	setAttr ".r" -type "double3" 89.999907300475428 -83.07028463606801 179.99999999999926 ;
	setAttr ".roc" yes;
	setAttr ".dwut" 4;
	setAttr ".dtce" yes;
createNode joint -n "ctrl_j_pelvis" -p "ctrl_cog";
	rename -uid "43E24203-4303-B210-E533-D98FDF23E12C";
	setAttr ".t" -type "double3" 0.78062339410000181 -0.00024205536579999994 23.815655130000003 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -89.999937157695356 -79.522222998277272 0 ;
createNode joint -n "ctrl_j_spine_01" -p "ctrl_j_pelvis";
	rename -uid "51DCE4CD-40CD-63A6-D736-9C9F3E3D157A";
	setAttr ".t" -type "double3" 8.5649995803833008 4.2790434767620979e-15 2.7946134714820081e-19 ;
	setAttr ".r" -type "double3" -5.8052437270308652e-05 2.8407708912378286e-06 0.42145486402607601 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 9.4787915988670522e-23 -9.089798069509765e-06 -8.3166974990965734 ;
createNode joint -n "ctrl_j_spine_02" -p "ctrl_j_spine_01";
	rename -uid "AE8E1677-4289-A56D-56F9-1A96E0BCD6DE";
	setAttr ".t" -type "double3" 11.08899974822998 -5.1070259132757201e-15 1.8709805840039229e-15 ;
	setAttr ".r" -type "double3" -1.6712663166534947e-05 1.243278905419812e-05 -0.23789372380643145 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -6.1406620178765142e-05 -9.785593279608687e-06 -9.0543685694734037 ;
createNode joint -n "ctrl_j_spine_03" -p "ctrl_j_spine_02";
	rename -uid "57066EE2-4D1F-8774-0F84-6B9A4BE65D97";
	setAttr ".t" -type "double3" 11.324000358581543 -7.1054273576010019e-15 -3.8467493079785697e-16 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -9.2297311095733187e-05 -0.0020204221505627298 5.2311566360987092 ;
createNode orientConstraint -n "ctrl_j_spine_03_orientConstraint1" -p "ctrl_j_spine_03";
	rename -uid "482CC121-40B4-BE6E-CD29-5CA434F2DF6E";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_spine_03W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 9.3581793383037704e-05 -8.5693221279593137e-06 0.036426292161934867 ;
	setAttr ".rsrr" -type "double3" 1.3117322533700571e-06 1.6148074027412236e-07 0.036486499702915356 ;
	setAttr -k on ".w0";
createNode joint -n "ctrl_j_neck" -p "ctrl_j_spine_03";
	rename -uid "F9418BA5-4091-F6B1-D32C-09B9C7465D09";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.21065254627014e-05 0.0020191701380659847 0.68705899474649679 ;
createNode joint -n "ctrl_j_head" -p "ctrl_j_neck";
	rename -uid "FDE85FF9-4027-8712-0C3C-9AABE10EAFA7";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
	setAttr ".jo" -type "double3" -2.6660245825919083e-08 7.0271370856410289e-11 1.6131789247156361e-09 ;
createNode joint -n "ctrl_j_r_ear_01" -p "ctrl_j_head";
	rename -uid "D7FF7610-4128-EBD5-C1B0-3CBC8AD224DB";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 89.999882078317881 -27.90473848103543 -176.72190984925365 ;
	setAttr ".radi" 0.82655318707067649;
createNode joint -n "ctrl_j_r_ear_02" -p "ctrl_j_r_ear_01";
	rename -uid "C34806FE-4313-1644-3A7E-5D98D4A87239";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".radi" 0.82655318707067649;
createNode parentConstraint -n "ctrl_j_r_ear_02_parentConstraint1" -p "ctrl_j_r_ear_02";
	rename -uid "ED8D1A53-410D-F9C8-11B8-E0A07EF8D30B";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_ear_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -2.0116175392104196e-06 1.26043983073032e-06 
		-5.2857600962852302e-08 ;
	setAttr ".rst" -type "double3" -8.4454408262792242 -0.52916621476529713 -0.030270579238443673 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_ear_01_parentConstraint1" -p "ctrl_j_r_ear_01";
	rename -uid "407167A3-4ED0-82D1-907E-8DA395BCFDB4";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_ear_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 8.3689347718518547e-07 5.7712270518095465e-09 
		-8.9676850834052857e-08 ;
	setAttr ".tg[0].tor" -type "double3" 4.2215284229032695e-08 -2.2208805316914047e-08 
		3.8718800470264252e-09 ;
	setAttr ".lr" -type "double3" -4.221530509342541e-08 2.2208803513121979e-08 -3.8718895968721508e-09 ;
	setAttr ".rst" -type "double3" 27.418355863085836 -2.7953044747212044 -9.9156750924805444 ;
	setAttr ".rsrr" -type "double3" -4.221530509342541e-08 2.2208803513121979e-08 -3.8718895968721508e-09 ;
	setAttr -k on ".w0";
createNode joint -n "ctrl_j_l_ear_01" -p "ctrl_j_head";
	rename -uid "10035405-4F92-F0F7-BCB9-A0818DA248E1";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 90.000117921695107 -27.904750418311501 3.2779797753397091 ;
	setAttr ".radi" 0.82655318707067649;
createNode joint -n "ctrl_j_l_ear_02" -p "ctrl_j_l_ear_01";
	rename -uid "D5783FB9-49C7-5AB8-5B60-FB86FE985166";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".radi" 0.82655318707067649;
createNode parentConstraint -n "ctrl_j_l_ear_02_parentConstraint1" -p "ctrl_j_l_ear_02";
	rename -uid "B27B543A-4E25-B92A-A6FD-E5B4A802D5FD";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_ear_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.1132205912645077e-06 1.0146895803586631e-06 
		-5.8028646776620008e-08 ;
	setAttr ".rst" -type "double3" 8.4454530723674992 0.52919787198104018 0.03027428227998552 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_ear_01_parentConstraint1" -p "ctrl_j_l_ear_01";
	rename -uid "3B9A5708-437A-1508-EDF5-4BAE86DB1668";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_ear_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -7.1360472020387533e-07 1.7774597438346973e-07 
		-1.4438426454432829e-07 ;
	setAttr ".tg[0].tor" -type "double3" -3.1973835957807661e-08 1.7080211072393715e-08 
		-1.6936612706527301e-09 ;
	setAttr ".lr" -type "double3" 3.1973824396608258e-08 -1.7080211570313265e-08 1.6936612658869362e-09 ;
	setAttr ".rst" -type "double3" 27.418378696618419 -2.7953364177248243 9.9156641699556847 ;
	setAttr ".rsrr" -type "double3" 3.1973824396608258e-08 -1.7080211570313265e-08 1.6936612658869362e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_head_parentConstraint1" -p "ctrl_j_head";
	rename -uid "FBD2B050-4AE6-DFEE-B561-83A8158DC069";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_headW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".rst" -type "double3" 1.3518690992896225 0.00043311669487211546 3.688599266470278e-08 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_neck_parentConstraint1" -p "ctrl_j_neck";
	rename -uid "AFFF67D2-41E4-B05E-7CAD-028746438217";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_neckW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 4.2064677737637378e-08 -3.7802541894345348e-10 1.3071867798619498e-09 ;
	setAttr ".rst" -type "double3" 1.1750374490000031 -4.7037629887106663e-14 62.777683679999988 ;
	setAttr ".rsrr" -type "double3" 4.6823489909577617e-09 7.0252091750806421e-11 1.3058785022275246e-09 ;
	setAttr -k on ".w0";
createNode ikEffector -n "effector1" -p "ctrl_j_spine_02";
	rename -uid "1E0281E4-4E82-A8CD-2A10-75846E57CCE1";
	setAttr ".v" no;
	setAttr ".hd" yes;
createNode joint -n "ctrl_j_tail_01" -p "ctrl_j_spine_01";
	rename -uid "0CB2C111-41A1-6D07-F34E-BCB3B644E6A4";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "xzy";
	setAttr ".jo" -type "double3" 6.1570430181975621e-05 1.480949906086389e-05 -92.362546929362139 ;
createNode joint -n "ctrl_j_tail_02" -p "ctrl_j_tail_01";
	rename -uid "15FFCCF5-41E5-43B9-F206-55AA085DB4E6";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -6.2180969713973282e-05 2.3696978997167331e-23 0.22160627633843016 ;
createNode joint -n "ctrl_j_tail_03" -p "ctrl_j_tail_02";
	rename -uid "AB778C01-4E4F-7FB1-2C1A-6DB91DC45801";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode joint -n "ctrl_j_tail_04" -p "ctrl_j_tail_03";
	rename -uid "DE3C3899-44F9-B662-028F-C0A05A94FBD3";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode joint -n "ctrl_j_tail_05" -p "ctrl_j_tail_04";
	rename -uid "D961C160-4500-672C-5037-BFA43E903B71";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jot" -type "string" "none";
createNode parentConstraint -n "ctrl_j_tail_05_parentConstraint1" -p "ctrl_j_tail_05";
	rename -uid "06EC9A22-4CC2-2C10-AA9D-03B804BBF64B";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_tail_05W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.4992528463153576e-07 -3.8623144504867923e-07 
		-2.1730616203464532e-07 ;
	setAttr ".rst" -type "double3" 14.702116910693192 -0.05686453467914987 1.4555276743541981e-09 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_tail_04_parentConstraint1" -p "ctrl_j_tail_04";
	rename -uid "9A931F79-4928-41EE-F8E4-91B2C2F0EA60";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_tail_04W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.8160697052849173e-06 -3.8898200216408441e-07 
		-1.5559386673141398e-07 ;
	setAttr ".rst" -type "double3" 14.092836333001369 -0.055406428956718656 -1.2015398894723238e-13 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_tail_03_parentConstraint1" -p "ctrl_j_tail_03";
	rename -uid "9056F276-433E-665B-34E4-5A80C3CEB9CE";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_tail_03W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -2.1202943045750544e-07 -2.8880252500584902e-07 
		-9.6439012991416011e-08 ;
	setAttr ".rst" -type "double3" 12.26724798623653 4.3847521169482206e-09 6.8841802123743889e-10 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_tail_02_parentConstraint1" -p "ctrl_j_tail_02";
	rename -uid "3AC63213-4668-8BAB-A9DB-1FB1010E1183";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_tail_02W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 1.610649658090324e-07 2.6743036229959216e-07 
		-4.4947743147571331e-08 ;
	setAttr ".tg[0].tor" -type "double3" 7.7357867892284762e-10 1.5586363263077569e-14 
		-1.436165633486795e-08 ;
	setAttr ".lr" -type "double3" -5.3909682267847475e-10 -1.5586971011592758e-14 1.436239511808082e-08 ;
	setAttr ".rst" -type "double3" 6.6487777640000028 -1.6703971539300255e-09 1.8128402425043877e-15 ;
	setAttr ".rsrr" -type "double3" -7.7357867893992487e-10 -1.5586169319426806e-14 
		1.4361656384559884e-08 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_tail_01_parentConstraint1" -p "ctrl_j_tail_01";
	rename -uid "BD7DF083-4561-FBB8-BA7C-6F993B01C54E";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_tail_01W0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.1899950980165386e-07 2.6999999036547706e-07 
		-9.2729625414649918e-10 ;
	setAttr ".tg[0].tor" -type "double3" 1.1761163353587002e-09 6.2712913266350443e-09 
		-7.3250070777799107e-13 ;
	setAttr ".lr" -type "double3" -1.1761163356559954e-09 -6.2712913266380701e-09 7.41106338341435e-13 ;
	setAttr ".rst" -type "double3" -1.9236174767548491 -8.4615495033081736 0.00023990247892483491 ;
	setAttr ".rsrr" -type "double3" -1.1761163353435732e-09 -6.2712913266380684e-09 
		7.2202301025268842e-13 ;
	setAttr -k on ".w0";
createNode joint -n "ctrl_j_pelvis_low" -p "ctrl_j_pelvis";
	rename -uid "7324433F-43FD-A9C3-4932-0C9FAF29E884";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.9090355186227549e-05 -7.3297872821336004e-08 0.21998743728525655 ;
createNode parentConstraint -n "ctrl_j_pelvis_low_parentConstraint1" -p "ctrl_j_pelvis_low";
	rename -uid "12CBA5E0-4910-D7B5-284C-378940C6C7AE";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_pelvis_lowW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -2.1316282072803006e-14 -3.9968028886505635e-15 
		-1.7330971727180788e-16 ;
	setAttr ".tg[0].tor" -type "double3" 89.999988640204904 6.1807284993730045e-05 79.742191339997092 ;
	setAttr ".lr" -type "double3" 89.999988567245254 6.1798875929739488e-05 79.522222998277471 ;
	setAttr ".rst" -type "double3" -3.5527136788005009e-15 8.8817841970012523e-16 -1.7341813748905643e-16 ;
	setAttr ".rsrr" -type "double3" 89.999988567245225 6.1798875929739488e-05 79.522222998277471 ;
	setAttr -k on ".w0";
createNode orientConstraint -n "ctrl_j_pelvis_orientConstraint1" -p "ctrl_j_pelvis";
	rename -uid "E34BCE61-41D0-FD71-CC87-A2A898CA9E46";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ik_j_pelvisW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 6.354992298998541e-15 3.1927595099798382e-15 -0.21996834172289514 ;
	setAttr ".rsrr" -type "double3" 6.3549922989985418e-15 3.1927595099798382e-15 -0.21996834172289514 ;
	setAttr -k on ".w0";
createNode transform -n "grp_l_leg" -p "ctrl_world";
	rename -uid "E985FD78-4926-C9BD-5B8B-FAB86009F4F7";
	setAttr ".t" -type "double3" -1.4359733665634682e-30 -1.0658141036401503e-14 -2.5163382037329768e-25 ;
	setAttr ".r" -type "double3" 89.999999999999986 0 89.999999999999986 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1 1 ;
createNode transform -n "prnt_l_foot" -p "grp_l_leg";
	rename -uid "AA90273B-4DB6-FA6A-C26B-EAAE4FD24D69";
	setAttr ".t" -type "double3" 1.9893427450664957e-49 1.0947644252800719e-47 -4.9303806576312888e-32 ;
	setAttr ".rp" -type "double3" 1.0287692340000001 7.113139125 -0.045858531729999999 ;
	setAttr ".sp" -type "double3" 1.0287692340000001 7.113139125 -0.045858531729999999 ;
createNode transform -n "offset_l_foot" -p "prnt_l_foot";
	rename -uid "ACD45090-4699-1B2D-3315-F79D6339C9D2";
	setAttr ".t" -type "double3" 1.0287692338320682 7.1131391250242908 -0.045858531729998792 ;
	setAttr ".r" -type "double3" 0 0 -89.999999998647283 ;
	setAttr ".s" -type "double3" 1.0000000000000004 1.0000000000000002 1 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005017e-15 0 ;
	setAttr ".rpt" -type "double3" -3.5527136788005017e-15 3.5527136787166245e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 -7.8886090522101198e-31 0 ;
createNode transform -n "ctrl_l_foot" -p "offset_l_foot";
	rename -uid "D194215E-4BF4-79A0-57D8-5F89FEE8B7B3";
	setAttr ".rp" -type "double3" -2.7526851908987737e-08 2.0684444379526212e-08 -4.603215586485021e-10 ;
	setAttr ".sp" -type "double3" -2.7526851908987737e-08 2.0684444379526212e-08 -4.603215586485021e-10 ;
createNode mesh -n "ctrl_l_footShape" -p "ctrl_l_foot";
	rename -uid "23503E3B-44CB-450E-E7D7-F68A9FBB1E28";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.375 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 39 ".uvst[0].uvsp[0:38]" -type "float2" 0.375 0 0.5 0 0.625
		 0 0.375 0.125 0.5 0.125 0.625 0.125 0.375 0.25 0.5 0.25 0.625 0.25 0.375 0.375 0.5
		 0.375 0.625 0.375 0.375 0.5 0.5 0.5 0.625 0.5 0.375 0.625 0.5 0.625 0.625 0.625 0.375
		 0.75 0.5 0.75 0.625 0.75 0.375 0.875 0.5 0.875 0.625 0.875 0.375 1 0.5 1 0.625 1
		 0.875 0 0.75 0 0.875 0.125 0.75 0.125 0.875 0.25 0.75 0.25 0.125 0 0.25 0 0.125 0.125
		 0.25 0.125 0.125 0.25 0.25 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 26 ".pt[0:25]" -type "float3"  2.8081546 -4.9511018 3.9508443 
		3.2104273 -2.0889001 3.9508443 1.7368317 0.15743876 3.9508443 0.61025524 -6.2133865 
		3.9508443 0.11025524 -2.5889006 3.9508443 -0.38974476 0.50080204 3.9508443 -1.5876439 
		-5.9511023 3.9508443 -2.9899168 -3.0889006 3.9508443 -2.5163212 -0.84256077 3.9508443 
		-1.7476428 -5.9835567 2.0190332 -3.0458984 -3.0889006 1.8430988 -2.9567003 0.52129936 
		1.6448191 -1.0685883 -5.4123707 0.54585862 -2.4914198 -3.0889006 0.54585862 -2.4724226 
		-0.19938374 0.54585862 0.61025524 -5.7817516 0.54585862 0.11025524 -2.5889006 0.54585862 
		-0.38974476 1.4312782 0.54585862 2.2890992 -4.4123712 0.54585862 2.7119312 -2.0889001 
		0.54585862 1.6929331 0.80061626 0.54585862 2.968153 -4.9835567 2.0190332 3.2664094 
		-2.0889001 1.8430988 2.1772146 1.5212991 1.6448191 -0.38974476 1.9947147 1.6556706 
		0.61025524 -6.5840788 2.095881;
	setAttr -s 26 ".vt[0:25]"  -0.5 -0.5 0.5 0 -0.5 0.5 0.5 -0.5 0.5 -0.5 0 0.5
		 0 0 0.5 0.5 0 0.5 -0.5 0.5 0.5 0 0.5 0.5 0.5 0.5 0.5 -0.5 0.5 0 0 0.5 0 0.5 0.5 0
		 -0.5 0.5 -0.5 0 0.5 -0.5 0.5 0.5 -0.5 -0.5 0 -0.5 0 0 -0.5 0.5 0 -0.5 -0.5 -0.5 -0.5
		 0 -0.5 -0.5 0.5 -0.5 -0.5 -0.5 -0.5 0 0 -0.5 0 0.5 -0.5 0 0.5 0 0 -0.5 0 0;
	setAttr -s 48 ".ed[0:47]"  0 1 0 1 2 0 3 4 1 4 5 1 6 7 0 7 8 0 9 10 1
		 10 11 1 12 13 0 13 14 0 15 16 1 16 17 1 18 19 0 19 20 0 21 22 1 22 23 1 0 3 0 1 4 1
		 2 5 0 3 6 0 4 7 1 5 8 0 6 9 0 7 10 1 8 11 0 9 12 0 10 13 1 11 14 0 12 15 0 13 16 1
		 14 17 0 15 18 0 16 19 1 17 20 0 18 21 0 19 22 1 20 23 0 21 0 0 22 1 1 23 2 0 17 24 1
		 24 5 1 23 24 1 24 11 1 15 25 1 25 3 1 21 25 1 25 9 1;
	setAttr -s 24 -ch 96 ".fc[0:23]" -type "polyFaces" 
		f 4 0 17 -3 -17
		mu 0 4 0 1 4 3
		f 4 1 18 -4 -18
		mu 0 4 1 2 5 4
		f 4 2 20 -5 -20
		mu 0 4 3 4 7 6
		f 4 3 21 -6 -21
		mu 0 4 4 5 8 7
		f 4 4 23 -7 -23
		mu 0 4 6 7 10 9
		f 4 5 24 -8 -24
		mu 0 4 7 8 11 10
		f 4 6 26 -9 -26
		mu 0 4 9 10 13 12
		f 4 7 27 -10 -27
		mu 0 4 10 11 14 13
		f 4 8 29 -11 -29
		mu 0 4 12 13 16 15
		f 4 9 30 -12 -30
		mu 0 4 13 14 17 16
		f 4 10 32 -13 -32
		mu 0 4 15 16 19 18
		f 4 11 33 -14 -33
		mu 0 4 16 17 20 19
		f 4 12 35 -15 -35
		mu 0 4 18 19 22 21
		f 4 13 36 -16 -36
		mu 0 4 19 20 23 22
		f 4 14 38 -1 -38
		mu 0 4 21 22 25 24
		f 4 15 39 -2 -39
		mu 0 4 22 23 26 25
		f 4 -37 -34 40 -43
		mu 0 4 28 27 29 30
		f 4 -40 42 41 -19
		mu 0 4 2 28 30 5
		f 4 -41 -31 -28 -44
		mu 0 4 30 29 31 32
		f 4 -42 43 -25 -22
		mu 0 4 5 30 32 8
		f 4 34 46 -45 31
		mu 0 4 33 34 36 35
		f 4 37 16 -46 -47
		mu 0 4 34 0 3 36
		f 4 44 47 25 28
		mu 0 4 35 36 38 37
		f 4 45 19 22 -48
		mu 0 4 36 3 6 38;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode ikHandle -n "ik_l_leg" -p "ctrl_l_foot";
	rename -uid "A899EF2F-4E2D-7381-6FB7-AC92FF2DAA47";
	setAttr ".t" -type "double3" 6.8704461573254605e-05 -2.9839326093252438 4.3181030484611131 ;
	setAttr ".r" -type "double3" 0 0 89.999999998647283 ;
	setAttr ".roc" yes;
createNode ikHandle -n "ik_l_foot" -p "ik_l_leg";
	rename -uid "5FB7ACF6-4D26-4B28-E8A0-8E813B220C04";
	setAttr ".t" -type "double3" 2.9839140333605183 6.8731988428716306e-05 -4.3180760815449659 ;
	setAttr ".pv" -type "double3" -1.6289818569124104 0.14605578854783763 -1.1511237190162806 ;
	setAttr ".roc" yes;
createNode poleVectorConstraint -n "ik_l_leg_poleVectorConstraint1" -p "ik_l_leg";
	rename -uid "724FBC76-4A94-321D-F600-1DAD4AEE3AD5";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_l_leg_PVW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".rst" -type "double3" -17.303350693923839 1.6738678807914935 -7.2670897754314971 ;
	setAttr -k on ".w0";
createNode transform -n "prnt_l_leg_PV" -p "grp_l_leg";
	rename -uid "3D10631E-4690-C8AE-69A5-8EA704E22D6B";
	setAttr ".t" -type "double3" 0.14771712074468113 6.5788842450034855 13.659909120000002 ;
	setAttr ".r" -type "double3" 45.370521149999945 -86.522006299999973 -135.41661279864735 ;
	setAttr ".s" -type "double3" 1 1.0000000000000002 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005017e-15 0 ;
	setAttr ".rpt" -type "double3" -3.5493958413228448e-15 3.5588404648935329e-15 -1.5338222722488805e-16 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 -7.8886090522101198e-31 0 ;
createNode transform -n "offset_l_leg_PV" -p "prnt_l_leg_PV";
	rename -uid "B421CE4C-46E1-CD82-2E4E-1DA07143C02A";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_l_leg_PV" -p "offset_l_leg_PV";
	rename -uid "CC891B98-4D40-BDC0-9F2D-8EA3D7B83678";
	setAttr ".rp" -type "double3" 0.73452813180995058 -16.984123897030063 1.0019908697378028 ;
	setAttr ".sp" -type "double3" 0.73452813180995058 -16.984123897030063 1.0019908697378028 ;
createNode nurbsCurve -n "ctrl_l_leg_PVShape" -p "ctrl_l_leg_PV";
	rename -uid "08A21143-42E8-7E67-04A2-10986AE2CAB7";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		-0.83172961141874657 -16.982395447491047 2.5701780790835631
		0.73589212549752681 -16.983805088285873 3.2183788022079991
		2.3027148534106114 -16.985401482919237 2.5682495339714571
		2.9509150681434324 -16.986249485065805 1.0006271824112065
		2.3007858750386543 -16.985852346569047 -0.56619633960796234
		0.73316413812238157 -16.984442705774221 -1.2143970627323994
		-0.83365858979070329 -16.982846311140861 -0.56426779449585651
		-1.4818588045235237 -16.981998308994292 1.0033545570643938
		-0.83172961141874657 -16.982395447491047 2.5701780790835631
		0.73589212549752681 -16.983805088285873 3.2183788022079991
		2.3027148534106114 -16.985401482919237 2.5682495339714571
		;
createNode nurbsCurve -n "ctrl_l_leg_PVShape1" -p "ctrl_l_leg_PV";
	rename -uid "8AEC0F7E-4889-ACB8-AE20-60B22A9C3728";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		0.73699549970739442 -15.416675952357362 2.5689874498726626
		0.73665352326630551 -14.767736564104279 1.0016707530865816
		0.73506652133543793 -15.417126816007176 -0.56545842370675703
		0.73316413812238146 -16.984442705774221 -1.214397062732399
		0.73206076391251396 -18.551571841702732 -0.56500571039706204
		0.73240274035360275 -19.200511229955815 1.0023109863890187
		0.73398974228447045 -18.551120978052918 2.5694401631823576
		0.73589212549752681 -16.983805088285873 3.218378802208
		0.73699549970739442 -15.416675952357362 2.5689874498726626
		0.73665352326630551 -14.767736564104279 1.0016707530865816
		0.73506652133543793 -15.417126816007176 -0.56545842370675703
		;
createNode nurbsCurve -n "ctrl_l_leg_PVShape2" -p "ctrl_l_leg_PV";
	rename -uid "C335EB91-4D19-B1C6-0697-B9B491C6A908";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		-0.83119122189326289 -15.415398366468176 1.0027287856390055
		0.7366535232663054 -14.767736564104279 1.0016707530865816
		2.303253242936095 -15.418404401896364 1.0008002405269001
		2.9509150681434324 -16.986249485065805 1.0006271824112063
		2.3002474855131707 -18.552849427591919 1.0012529538365951
		0.73240274035360298 -19.200511229955815 1.0023109863890189
		-0.83419697931618686 -18.54984339216373 1.0031814989487005
		-1.4818588045235237 -16.981998308994292 1.0033545570643942
		-0.83119122189326289 -15.415398366468176 1.0027287856390055
		0.7366535232663054 -14.767736564104279 1.0016707530865816
		2.303253242936095 -15.418404401896364 1.0008002405269001
		;
createNode joint -n "IK_ctrl_j_l_femur" -p "grp_l_leg";
	rename -uid "A72DD5BD-4D6F-E67A-7C94-718681921C21";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" -106.63439413151301 74.33103394496473 163.95137858352609 ;
createNode joint -n "IK_ctrl_j_l_knee" -p "IK_ctrl_j_l_femur";
	rename -uid "8608304C-4F3F-CF45-0AD7-78B79BABE953";
	setAttr ".t" -type "double3" 7.1655298197111605 1.6191676710362199 -0.11219989622897497 ;
	setAttr ".r" -type "double3" 4.072805813505701e-15 7.5691466984355355e-16 -2.9713730439916691e-13 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225637572013 178.04591234014012 17.576356065281974 ;
createNode joint -n "IK_ctrl_j_l_heel" -p "IK_ctrl_j_l_knee";
	rename -uid "05BEDD2B-4914-045F-1B66-2F927B7A149E";
	setAttr ".t" -type "double3" -3.3872198826893349 -2.8224589625693843 0.23631473678988524 ;
	setAttr ".r" -type "double3" 4.4281561614442154e-15 -3.4756940142788264e-14 3.6398489888939813e-13 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 0 0 179.99999999999997 ;
createNode joint -n "IK_ctrl_j_l_foot" -p "IK_ctrl_j_l_heel";
	rename -uid "58FA609A-4691-1B64-4603-6E93E3E853D7";
	setAttr ".t" -type "double3" 5.9150496043338219 -0.31537836291748467 -0.10238684840188661 ;
	setAttr ".r" -type "double3" 5.2185629505936646 -0.1132504931955244 -0.065550365203376551 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299210189117 5.4430146952341811 -23.175135144647015 ;
createNode joint -n "IK_ctrl_j_l_toe" -p "IK_ctrl_j_l_foot";
	rename -uid "D6C7AAAA-4F00-C5FE-F15C-0E8A576DE60F";
	setAttr ".t" -type "double3" 5.1907966380376838 0.77791659223574072 -7.0447647715354833e-11 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222922709 -89.999999999999815 0 ;
createNode ikEffector -n "effector5" -p "IK_ctrl_j_l_foot";
	rename -uid "17617A89-4B11-5DDC-9C03-6B99CD3336B1";
	setAttr ".v" no;
	setAttr ".hd" yes;
createNode ikEffector -n "effector2" -p "IK_ctrl_j_l_heel";
	rename -uid "68816599-47F5-3051-6804-DCB7984E75E7";
	setAttr ".v" no;
	setAttr ".hd" yes;
createNode parentConstraint -n "IK_ctrl_j_l_femur_parentConstraint1" -p "IK_ctrl_j_l_femur";
	rename -uid "3D04AD28-4A9B-195B-B9D2-3493043055E5";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_pelvis_lowW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.32967270061227327 5.9043497100375699 -2.8460376611041553 ;
	setAttr ".tg[0].tor" -type "double3" -110.55854498120381 74.529822014378908 167.19059637281529 ;
	setAttr ".lr" -type "double3" -7.0443048309227221 -0.89109070376208577 -0.034214958863566097 ;
	setAttr ".rst" -type "double3" 0.45095069531813875 5.9041076581246159 20.969617475847055 ;
	setAttr ".rsrr" -type "double3" -7.0443048309227025 -0.89109070376206911 -0.034214958863557708 ;
	setAttr -k on ".w0";
createNode joint -n "ctrl_j_l_femur" -p "grp_l_leg";
	rename -uid "9C52BCF3-4388-B1D7-571D-D881094FC61E";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" -106.63439413151303 74.33103394496473 163.95137858352606 ;
createNode joint -n "ctrl_j_l_knee" -p "ctrl_j_l_femur";
	rename -uid "94B9DAC2-472A-3824-6618-B0B9373A86FA";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225637572013 178.04591234014012 17.576356065281974 ;
createNode joint -n "ctrl_j_l_heel" -p "ctrl_j_l_knee";
	rename -uid "0607A1D9-4B6C-B106-03F8-AEA2B80682B0";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 0 0 179.99999999999997 ;
createNode joint -n "ctrl_j_l_foot" -p "ctrl_j_l_heel";
	rename -uid "6B93A989-4DF3-4C1A-4477-DB88FD3C298F";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299210189117 5.4430146952341847 -23.175135144647015 ;
createNode joint -n "ctrl_j_l_toe" -p "ctrl_j_l_foot";
	rename -uid "D0F69968-4AC4-E709-EB25-0992B368A26A";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222922709 -89.999999999999815 0 ;
createNode parentConstraint -n "ctrl_j_l_toe_parentConstraint1" -p "ctrl_j_l_toe";
	rename -uid "02A14B3E-4833-6525-9F85-C18853697198";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_l_toeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 3.1209290263234379e-08 1.8580462596395897e-05 
		-2.696954288650133e-05 ;
	setAttr ".tg[0].tor" -type "double3" -0.072066777033171589 -2.3801051492208827 3.4470938917497058 ;
	setAttr ".lr" -type "double3" -2.7034714792439894e-14 -3.1805546814635203e-15 -1.5902773407317584e-14 ;
	setAttr ".rst" -type "double3" 5.1907966380376855 0.77791659223574117 -7.0445871358515433e-11 ;
	setAttr ".rsrr" -type "double3" 6.3611093629270335e-15 3.975693351829396e-16 2.2069531490250793e-32 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_foot_parentConstraint1" -p "ctrl_j_l_foot";
	rename -uid "53708DE9-4CEE-21C5-90ED-47B20FEE0122";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_l_footW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 2.6843292379119532e-05 4.1860838147556034e-05 
		-7.162828440421265e-05 ;
	setAttr ".tg[0].tor" -type "double3" -4.1419326415986522 -0.62095522793401636 0.022016953779581971 ;
	setAttr ".lr" -type "double3" -4.373262687012332e-15 -1.590277340731759e-14 -3.8166656177562208e-14 ;
	setAttr ".rst" -type "double3" 5.9150496043338237 -0.31537836291748422 -0.10238684840188572 ;
	setAttr ".rsrr" -type "double3" -3.3793393490549872e-15 -9.3795508833565909e-32 
		-3.1805546814635176e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_heel_parentConstraint1" -p "ctrl_j_l_heel";
	rename -uid "7824E2D5-461F-0D44-7886-DF9EAC62A6E9";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_l_heelW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 0.00030031507363403875 -0.0066508260011155507 
		0.031965759961264162 ;
	setAttr ".tg[0].tor" -type "double3" 1.2834789263260513 0.24087249039822461 0.040851581231234571 ;
	setAttr ".lr" -type "double3" 6.7586786981099577e-15 2.5651715116572188e-14 -4.0952515799631678e-14 ;
	setAttr ".rst" -type "double3" -3.3872198826893332 -2.8224589625693852 0.23631473678988346 ;
	setAttr ".rsrr" -type "double3" -5.9635400277440939e-16 1.6791868893224575e-17 -1.5298317513366473e-17 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_knee_parentConstraint1" -p "ctrl_j_l_knee";
	rename -uid "69CE4465-4469-4877-D1B8-A2A049475622";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_l_kneeW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.0010802293936986729 0.0030646999087184934 
		-0.0169528398376384 ;
	setAttr ".tg[0].tor" -type "double3" -1.2834789263260509 -0.2408724903982247 0.04085158123123888 ;
	setAttr ".lr" -type "double3" -7.4792731181290396e-15 -2.7817429421081311e-14 -4.4527765540489235e-14 ;
	setAttr ".rst" -type "double3" 7.1655298197111588 1.6191676710362195 -0.11219989622897852 ;
	setAttr ".rsrr" -type "double3" -4.9696166897867437e-17 -1.2424041724466859e-17 
		5.3880692114870074e-36 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_l_femur_parentConstraint1" -p "ctrl_j_l_femur";
	rename -uid "5573C909-49C6-F677-0530-AEA1DAFA02C9";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_pelvis_lowW0" -dv 1 -min 0 
		-at "double";
	addAttr -dcb 0 -ci true -k true -sn "w1" -ln "IK_ctrl_j_l_femurW1" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr -s 2 ".tg";
	setAttr ".tg[0].tot" -type "double3" -0.32967270061227327 5.9043497100375699 -2.8460376611041553 ;
	setAttr ".tg[0].tor" -type "double3" -109.80274061484968 74.481078220072177 166.62910994489292 ;
	setAttr ".tg[1].tot" -type "double3" 0 4.4408920985006262e-16 1.7763568394002505e-15 ;
	setAttr ".tg[1].tor" -type "double3" 1.2968951100248542 0.15752776511908223 0.0077791525699537727 ;
	setAttr ".lr" -type "double3" -5.7472559451373852 -0.73379799275176116 -0.045814184847069256 ;
	setAttr ".rst" -type "double3" 0.45095069531813908 5.904107658124615 20.969617475847055 ;
	setAttr ".rsrr" -type "double3" -5.7472559451374048 -0.73379799275177637 -0.045814184847052443 ;
	setAttr -k on ".w0";
	setAttr -k on ".w1";
createNode transform -n "grp_r_leg" -p "ctrl_world";
	rename -uid "2B9C685A-4CDF-0868-1906-F4A3D1F6D444";
	setAttr ".t" -type "double3" -1.4359733665634682e-30 -1.0658141036401503e-14 -2.5163382037329768e-25 ;
	setAttr ".r" -type "double3" 89.999999999999986 0 89.999999999999986 ;
	setAttr ".s" -type "double3" 1.0000000000000002 1 1 ;
createNode transform -n "prnt_r_foot" -p "grp_r_leg";
	rename -uid "AC68287E-418F-617A-72E3-44B0AB2A24C1";
	setAttr ".t" -type "double3" 1.9893427450664957e-49 1.0947644252800719e-47 -4.9303806576312888e-32 ;
	setAttr ".rp" -type "double3" 1.02877 -7.11314 -0.045858500000000003 ;
	setAttr ".sp" -type "double3" 1.02877 -7.11314 -0.045858500000000003 ;
createNode transform -n "offset_r_foot" -p "prnt_r_foot";
	rename -uid "013B0077-4EDF-4951-0E73-AEA34ED02D73";
	setAttr ".t" -type "double3" 1.0287700001679321 -7.1131399999757114 -0.045858500000002245 ;
	setAttr ".r" -type "double3" -180 0 -89.999999998647283 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".rpt" -type "double3" 3.5527136788005009e-15 3.5527136788843781e-15 4.3508194350300514e-31 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_r_foot" -p "offset_r_foot";
	rename -uid "51C18CA5-441C-6DE7-BAA3-A9B8526E3A79";
	setAttr ".rp" -type "double3" 0.00047980438232466435 3.0059810862681502e-08 -1.337288837659083e-09 ;
	setAttr ".sp" -type "double3" 0.00047980438232466435 3.0059810862681502e-08 -1.337288837659083e-09 ;
createNode mesh -n "ctrl_r_footShape" -p "ctrl_r_foot";
	rename -uid "793BD898-49EF-D110-57AA-4299CB93D276";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".pv" -type "double2" 0.375 0.5 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 39 ".uvst[0].uvsp[0:38]" -type "float2" 0.375 0 0.5 0 0.625
		 0 0.375 0.125 0.5 0.125 0.625 0.125 0.375 0.25 0.5 0.25 0.625 0.25 0.375 0.375 0.5
		 0.375 0.625 0.375 0.375 0.5 0.5 0.5 0.625 0.5 0.375 0.625 0.5 0.625 0.625 0.625 0.375
		 0.75 0.5 0.75 0.625 0.75 0.375 0.875 0.5 0.875 0.625 0.875 0.375 1 0.5 1 0.625 1
		 0.875 0 0.75 0 0.875 0.125 0.75 0.125 0.875 0.25 0.75 0.25 0.125 0 0.25 0 0.125 0.125
		 0.25 0.125 0.125 0.25 0.25 0.25;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 26 ".pt[0:25]" -type "float3"  -1.8081555 5.9511027 -4.9508438 
		-3.2104282 3.088901 -4.9508438 -2.7368326 0.84256172 -4.9508438 0.3897438 6.2133875 
		-4.9508438 -0.11025608 2.5889015 -4.9508438 -0.61025608 -0.50080156 -4.9508438 2.5876427 
		4.9511032 -4.9508438 2.9899158 2.0889015 -4.9508438 1.5163203 -0.15743828 -4.9508438 
		2.7476416 4.9835577 -2.019033 3.0458975 2.0889015 -1.8430986 1.9566985 -1.5212984 
		-1.644819 2.0685873 4.4123716 0.45414138 2.4914188 2.0889015 0.45414138 1.4724219 
		-0.80061531 0.45414138 0.3897438 5.7817526 0.45414138 -0.11025608 2.5889015 0.45414138 
		-0.6102562 -1.4312773 0.45414138 -1.2891002 5.4123721 0.45414138 -2.7119322 3.088901 
		0.45414138 -2.692934 0.19938469 0.45414138 -1.9681538 5.9835577 -2.019033 -3.2664104 
		3.088901 -1.8430986 -3.1772156 -0.52129841 -1.644819 -0.6102562 -1.9947138 -1.6556705 
		0.3897438 6.5840797 -2.0958807;
	setAttr -s 26 ".vt[0:25]"  -0.5 -0.5 0.5 0 -0.5 0.5 0.5 -0.5 0.5 -0.5 0 0.5
		 0 0 0.5 0.5 0 0.5 -0.5 0.5 0.5 0 0.5 0.5 0.5 0.5 0.5 -0.5 0.5 0 0 0.5 0 0.5 0.5 0
		 -0.5 0.5 -0.5 0 0.5 -0.5 0.5 0.5 -0.5 -0.5 0 -0.5 0 0 -0.5 0.5 0 -0.5 -0.5 -0.5 -0.5
		 0 -0.5 -0.5 0.5 -0.5 -0.5 -0.5 -0.5 0 0 -0.5 0 0.5 -0.5 0 0.5 0 0 -0.5 0 0;
	setAttr -s 48 ".ed[0:47]"  0 1 0 1 2 0 3 4 1 4 5 1 6 7 0 7 8 0 9 10 1
		 10 11 1 12 13 0 13 14 0 15 16 1 16 17 1 18 19 0 19 20 0 21 22 1 22 23 1 0 3 0 1 4 1
		 2 5 0 3 6 0 4 7 1 5 8 0 6 9 0 7 10 1 8 11 0 9 12 0 10 13 1 11 14 0 12 15 0 13 16 1
		 14 17 0 15 18 0 16 19 1 17 20 0 18 21 0 19 22 1 20 23 0 21 0 0 22 1 1 23 2 0 17 24 1
		 24 5 1 23 24 1 24 11 1 15 25 1 25 3 1 21 25 1 25 9 1;
	setAttr -s 24 -ch 96 ".fc[0:23]" -type "polyFaces" 
		f 4 16 2 -18 -1
		mu 0 4 0 3 4 1
		f 4 17 3 -19 -2
		mu 0 4 1 4 5 2
		f 4 19 4 -21 -3
		mu 0 4 3 6 7 4
		f 4 20 5 -22 -4
		mu 0 4 4 7 8 5
		f 4 22 6 -24 -5
		mu 0 4 6 9 10 7
		f 4 23 7 -25 -6
		mu 0 4 7 10 11 8
		f 4 25 8 -27 -7
		mu 0 4 9 12 13 10
		f 4 26 9 -28 -8
		mu 0 4 10 13 14 11
		f 4 28 10 -30 -9
		mu 0 4 12 15 16 13
		f 4 29 11 -31 -10
		mu 0 4 13 16 17 14
		f 4 31 12 -33 -11
		mu 0 4 15 18 19 16
		f 4 32 13 -34 -12
		mu 0 4 16 19 20 17
		f 4 34 14 -36 -13
		mu 0 4 18 21 22 19
		f 4 35 15 -37 -14
		mu 0 4 19 22 23 20
		f 4 37 0 -39 -15
		mu 0 4 21 24 25 22
		f 4 38 1 -40 -16
		mu 0 4 22 25 26 23
		f 4 42 -41 33 36
		mu 0 4 28 30 29 27
		f 4 18 -42 -43 39
		mu 0 4 2 5 30 28
		f 4 43 27 30 40
		mu 0 4 30 32 31 29
		f 4 21 24 -44 41
		mu 0 4 5 8 32 30
		f 4 -32 44 -47 -35
		mu 0 4 33 35 36 34
		f 4 46 45 -17 -38
		mu 0 4 34 36 3 0
		f 4 -29 -26 -48 -45
		mu 0 4 35 37 38 36
		f 4 47 -23 -20 -46
		mu 0 4 36 38 6 3;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
createNode ikHandle -n "ik_r_leg" -p "ctrl_r_foot";
	rename -uid "56F23EE0-41B3-10F9-174D-FA9C49E5B788";
	setAttr ".t" -type "double3" -6.8704482076853424e-05 2.9839336246304802 -4.3181012526599245 ;
	setAttr ".r" -type "double3" 180 0 -89.999999998647283 ;
	setAttr ".roc" yes;
createNode ikHandle -n "ik_r_foot" -p "ik_r_leg";
	rename -uid "DCD3476F-4DB0-4176-32F7-15B4DB4926E3";
	setAttr ".t" -type "double3" 2.9839335945706691 -6.8810683250042359e-05 -4.3181012513226351 ;
	setAttr ".pv" -type "double3" -1.6461664503813132 -0.14814626777847495 -1.126138846227364 ;
	setAttr ".roc" yes;
createNode poleVectorConstraint -n "ik_r_leg_poleVectorConstraint1" -p "ik_r_leg";
	rename -uid "01A81CED-4714-FBFB-3A78-9F98931A4035";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_r_leg_PVW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".rst" -type "double3" -17.303116884216504 -1.6738636315567383 -7.3523063426885056 ;
	setAttr -k on ".w0";
createNode transform -n "prnt_r_leg_PV" -p "grp_r_leg";
	rename -uid "F8B5E76F-44F9-2C50-0BAA-639A96B3CF01";
	setAttr ".t" -type "double3" 0.14771699920928089 -6.5788822174037414 13.659912109374998 ;
	setAttr ".r" -type "double3" 45.370521149999945 -86.522006299999973 -135.41661279864735 ;
	setAttr ".s" -type "double3" 1 1.0000000000000002 1.0000000000000002 ;
	setAttr ".rp" -type "double3" 0 -3.5527136788005017e-15 0 ;
	setAttr ".rpt" -type "double3" -3.5493958413228448e-15 3.5588404648935329e-15 -1.5338222722488805e-16 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".spt" -type "double3" 0 -7.8886090522101198e-31 0 ;
createNode transform -n "offset_r_leg_PV" -p "prnt_r_leg_PV";
	rename -uid "FB8EF8D9-49A4-22EC-06E2-528BBF49F6C0";
	setAttr ".rp" -type "double3" 0 -3.5527136788005009e-15 0 ;
	setAttr ".sp" -type "double3" 0 -3.5527136788005009e-15 0 ;
createNode transform -n "ctrl_r_leg_PV" -p "offset_r_leg_PV";
	rename -uid "DECAFF6F-4648-179B-5C72-1E808B8E419A";
	setAttr ".rp" -type "double3" 0.73452799845992089 -16.984123900144489 -0.99800901559777166 ;
	setAttr ".sp" -type "double3" 0.73452799845992089 -16.984123900144489 -0.99800901559777166 ;
createNode nurbsCurve -n "ctrl_r_leg_PVShape" -p "ctrl_r_leg_PV";
	rename -uid "37C30C9C-4C7F-A632-EBDC-CFA92F068439";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		2.1616684777003918 -16.991486262361999 0.69774841913550611
		0.54457647594756797 -16.992080047628622 1.210210300532256
		-0.96124450011094009 -16.988013229603286 0.42912725523427842
		-1.4737049452059425 -16.981668095129518 -1.187952862162551
		-0.69261248078054338 -16.976761537926983 -2.6937664503310481
		0.92447952097228447 -16.976167752660363 -3.206228331727798
		2.4303004970307889 -16.980234570685699 -2.42514528642982
		2.9427609421257932 -16.986579705159464 -0.80806516903298964
		2.1616684777003918 -16.991486262361999 0.69774841913550611
		0.54457647594756797 -16.992080047628622 1.210210300532256
		-0.96124450011094009 -16.988013229603286 0.42912725523427842
		;
createNode nurbsCurve -n "ctrl_r_leg_PVShape1" -p "ctrl_r_leg_PV";
	rename -uid "5C7D8E3B-48EE-EA33-A22D-B8A956EC76B0";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		0.59896400615591738 -18.55696193615605 0.55768386726286079
		0.73276308448651539 -19.200496634604168 -1.0061463578989931
		0.86759602548631398 -18.54571024447975 -2.5652098383024642
		0.92447952097228447 -16.976167752660363 -3.206228331727798
		0.87009199076393307 -15.411285864132934 -2.5537018984584017
		0.73629291243333872 -14.767751165684819 -0.98987167329654657
		0.60145997143353835 -15.422537555809233 0.56919180710692308
		0.54457647594756797 -16.992080047628622 1.2102103005322569
		0.59896400615591738 -18.55696193615605 0.55768386726286079
		0.73276308448651539 -19.200496634604168 -1.0061463578989931
		0.86759602548631398 -18.54571024447975 -2.5652098383024642
		;
createNode nurbsCurve -n "ctrl_r_leg_PVShape2" -p "ctrl_r_leg_PV";
	rename -uid "6CE58AB8-4908-C838-94E3-ACB4BD2671B1";
	setAttr -k off ".v";
	setAttr ".cc" -type "nurbsCurve" 
		3 8 2 no 3
		13 -2 -1 0 1 2 3 4 5 6 7 8 9 10
		11
		2.2947365047267807 -18.553072606697256 -0.86945240356918729
		0.7327630844865155 -19.200496634604168 -1.006146357898994
		-0.82817647308455045 -18.549599573938544 -1.1380735674704157
		-1.4737049452059425 -16.981668095129518 -1.187952862162551
		-0.82568050780693125 -15.415175193591727 -1.1265656276263536
		0.73629291243333694 -14.767751165684819 -0.98987167329654668
		2.2972324700044009 -15.418648226350443 -0.85794446372512589
		2.9427609421257932 -16.986579705159464 -0.80806516903298964
		2.2947365047267807 -18.553072606697256 -0.86945240356918729
		0.7327630844865155 -19.200496634604168 -1.006146357898994
		-0.82817647308455045 -18.549599573938544 -1.1380735674704157
		;
createNode joint -n "IK_ctrl_j_r_femur" -p "grp_r_leg";
	rename -uid "F229E22A-4B22-4378-E778-1F815CFB9369";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 73.365605868487009 -74.33103394496473 16.048621419179362 ;
createNode joint -n "IK_ctrl_j_r_knee" -p "IK_ctrl_j_r_femur";
	rename -uid "28269DC1-42B3-7F40-63D7-6997082ED7A0";
	setAttr ".t" -type "double3" -7.1655101418040505 -1.6191619138864937 0.11219730317127397 ;
	setAttr ".r" -type "double3" 1.8881565276373613e-15 2.7647142580642294e-16 -1.4855592485472484e-13 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225630549339 178.04591234014006 17.576356065281974 ;
createNode joint -n "IK_ctrl_j_r_heel" -p "IK_ctrl_j_r_knee";
	rename -uid "C3EA354F-43F0-7941-E85D-3F8890054504";
	setAttr ".t" -type "double3" 3.3871896155177161 2.8224545928605558 -0.23631908512468414 ;
	setAttr ".r" -type "double3" 2.2162880232549584e-15 -1.735972555423059e-14 1.819840443396255e-13 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.9090959104164237e-06 0 -180 ;
createNode joint -n "IK_ctrl_j_r_foot" -p "IK_ctrl_j_r_heel";
	rename -uid "E403566F-448A-A3C0-4EFD-C0AE7A6A9B8A";
	setAttr ".t" -type "double3" -5.9150844878198878 0.31537365700334052 0.10238840764892743 ;
	setAttr ".r" -type "double3" 5.2932915133681915 -0.11497589898710661 -0.066114110290803038 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299386489367 5.4430139439201444 -23.175135311877707 ;
createNode joint -n "IK_ctrl_j_r_toe" -p "IK_ctrl_j_r_foot";
	rename -uid "6BFC7EF6-4C93-58C1-BAE3-D8B653A3B6E2";
	setAttr ".t" -type "double3" -5.1907954725309597 -0.77791829420210379 7.0389916118074325e-11 ;
	setAttr ".r" -type "double3" 1.526666247102488e-13 -3.7587943252935541e-24 1.3486887682371525e-09 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222923039 -89.999999999997286 0 ;
createNode ikEffector -n "effector4" -p "IK_ctrl_j_r_foot";
	rename -uid "12DA1C68-4FBD-37B6-00B3-7A8E7144A2E4";
	setAttr ".v" no;
	setAttr ".hd" yes;
createNode ikEffector -n "effector3" -p "IK_ctrl_j_r_heel";
	rename -uid "7B74E150-4808-F2E6-0B69-DDB32FC95C53";
	setAttr ".v" no;
	setAttr ".hd" yes;
createNode parentConstraint -n "IK_ctrl_j_r_femur_parentConstraint1" -p "IK_ctrl_j_r_femur";
	rename -uid "A01052AF-4314-6D91-A14E-CC91C170969F";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_pelvis_lowW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.32967239213003785 -5.9038679480764298 -2.8460551230494033 ;
	setAttr ".tg[0].tor" -type "double3" 69.430549425130238 -74.530540188880636 12.801337111653021 ;
	setAttr ".lr" -type "double3" -7.0629877476330032 -0.89335067293019477 -0.034019293220633351 ;
	setAttr ".rst" -type "double3" 0.45095100013939549 -5.9041099999893634 20.969599999999989 ;
	setAttr ".rsrr" -type "double3" -7.0629877476330032 -0.89335067293019421 -0.034019293220623824 ;
	setAttr -k on ".w0";
createNode joint -n "ctrl_j_r_femur" -p "grp_r_leg";
	rename -uid "0FEC0422-4834-BAC7-367A-08BB0F67C678";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 73.365605868486966 -74.331033944964702 16.04862141917932 ;
createNode joint -n "ctrl_j_r_knee" -p "ctrl_j_r_femur";
	rename -uid "3E8DD666-4D65-DD9A-F533-088C86C21FDE";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".dla" yes;
	setAttr ".jo" -type "double3" 0.086421225630549339 178.04591234014006 17.576356065281974 ;
createNode joint -n "ctrl_j_r_heel" -p "ctrl_j_r_knee";
	rename -uid "2BC3909C-4E72-A7B5-6A4B-5D803A3A73F8";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" 1.9090959104164237e-06 6.1223328560371377e-23 -180 ;
createNode joint -n "ctrl_j_r_foot" -p "ctrl_j_r_heel";
	rename -uid "0CB005EC-4975-4EC9-547E-4CAE0A938F96";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -176.26299386489367 5.443013943920147 -23.1751353118777 ;
createNode joint -n "ctrl_j_r_toe" -p "ctrl_j_r_foot";
	rename -uid "FD3AF219-4606-086F-ACEB-52817F2B0703";
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".jo" -type "double3" -26.121939222923036 -89.999999999997272 0 ;
createNode parentConstraint -n "ctrl_j_r_toe_parentConstraint1" -p "ctrl_j_r_toe";
	rename -uid "EFA8F87C-4842-6A48-98DB-D89874CCB876";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_r_toeW0" -dv 1 -min 0 -at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -1.0420435359037583e-07 -1.8644471067030821e-05 
		2.6925305258052035e-05 ;
	setAttr ".tg[0].tor" -type "double3" -0.074129179170084727 -2.4140852001564874 3.4964404488061884 ;
	setAttr ".lr" -type "double3" 4.9298597562687134e-14 7.1284181798301037e-13 4.230137726346479e-13 ;
	setAttr ".rst" -type "double3" -5.1907954725309597 -0.77791829420210323 7.0388139761234925e-11 ;
	setAttr ".rsrr" -type "double3" -1.1131941385122306e-14 -1.1529510720305246e-14 
		-4.7708320221952728e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_foot_parentConstraint1" -p "ctrl_j_r_foot";
	rename -uid "A7CA12E0-4DDF-60F3-C43B-7C83D662489A";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_r_footW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -2.6854377809470975e-05 -4.178674517740788e-05 
		7.1667247112827681e-05 ;
	setAttr ".tg[0].tor" -type "double3" -4.2011567508807373 -0.6298090102646684 0.022664274618448856 ;
	setAttr ".lr" -type "double3" -6.2219600956129578e-14 8.4046157457673428e-13 6.3611093629269881e-14 ;
	setAttr ".rst" -type "double3" -5.9150844878198896 0.31537365700334052 0.10238840764892831 ;
	setAttr ".rsrr" -type "double3" 2.5842006786891076e-15 7.9513867036587909e-16 6.3611093629270335e-15 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_heel_parentConstraint1" -p "ctrl_j_r_heel";
	rename -uid "A80DDD13-49BC-71BF-57FB-C4A8D90604A1";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_r_heelW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" -0.00030552030765562677 0.0067513383245423331 
		-0.032424527813033066 ;
	setAttr ".tg[0].tor" -type "double3" 1.3019660298789062 0.24433820200596212 0.041482353190713368 ;
	setAttr ".lr" -type "double3" -5.1285344319622073e-14 -6.3662539524769567e-15 -8.5759264288936442e-15 ;
	setAttr ".rst" -type "double3" 3.3871896155177161 2.8224545928605567 -0.23631908512468236 ;
	setAttr ".rsrr" -type "double3" -3.9646941620580714e-16 -7.6680803093283097e-18 
		-9.5497658078141759e-18 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_knee_parentConstraint1" -p "ctrl_j_r_knee";
	rename -uid "C7F7B3F3-4C36-824F-4280-A89A7A1F0D19";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "IK_ctrl_j_r_kneeW0" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".tg[0].tot" -type "double3" 0.0010952542979580926 -0.0031056151050226077 
		0.017197876301793258 ;
	setAttr ".tg[0].tor" -type "double3" -1.3019660298957652 -0.24433820062376982 0.041482361332106456 ;
	setAttr ".lr" -type "double3" 5.1808253991026815e-14 6.4045935089626704e-15 -6.3611093629270312e-15 ;
	setAttr ".rst" -type "double3" -7.1655101418040505 -1.6191619138864937 0.11219730317127485 ;
	setAttr ".rsrr" -type "double3" 6.4605016967227689e-16 9.9392333795734899e-17 5.6035919799464909e-34 ;
	setAttr -k on ".w0";
createNode parentConstraint -n "ctrl_j_r_femur_parentConstraint1" -p "ctrl_j_r_femur";
	rename -uid "A23A8744-4999-1314-30B2-D7B82E367888";
	addAttr -dcb 0 -ci true -k true -sn "w0" -ln "ctrl_j_pelvis_lowW0" -dv 1 -min 0 
		-at "double";
	addAttr -dcb 0 -ci true -k true -sn "w1" -ln "IK_ctrl_j_r_femurW1" -dv 1 -min 0 
		-at "double";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr -s 2 ".tg";
	setAttr ".tg[0].tot" -type "double3" -0.32967239213003785 -5.9038679480764298 -2.8460551230494033 ;
	setAttr ".tg[0].tor" -type "double3" 70.197258894593389 -74.481078188874051 13.37089056601237 ;
	setAttr ".tg[1].tor" -type "double3" 1.3155753618106176 0.15979209630325397 0.0079142405627499485 ;
	setAttr ".lr" -type "double3" -5.7472559451373817 -0.73379799275174562 -0.045814184847079588 ;
	setAttr ".rst" -type "double3" 0.45095100013939549 -5.9041099999893634 20.969599999999989 ;
	setAttr ".rsrr" -type "double3" -5.747255945137316 -0.73379799275174562 -0.045814184847083182 ;
	setAttr -k on ".w0";
	setAttr -k on ".w1";
createNode transform -n "back";
	rename -uid "EEA5B326-4652-CED6-9A85-D4B8099DDDDE";
	setAttr ".v" no;
	setAttr ".t" -type "double3" -0.43377693560288477 1000.1 11.052205434756909 ;
	setAttr ".r" -type "double3" 90.000000000000014 -7.016709298534876e-15 180 ;
createNode camera -n "backShape" -p "back";
	rename -uid "0A6B9849-4C88-DDE6-D83A-C585CF17782D";
	setAttr -k off ".v";
	setAttr ".rnd" no;
	setAttr ".coi" 1000.1;
	setAttr ".ow" 31.692199170510893;
	setAttr ".imn" -type "string" "back1";
	setAttr ".den" -type "string" "back1_depth";
	setAttr ".man" -type "string" "back1_mask";
	setAttr ".hc" -type "string" "viewSet -b %camera";
	setAttr ".o" yes;
createNode lightLinker -s -n "lightLinker1";
	rename -uid "1686CCB8-47DB-EC0D-585A-7782CFFE97F1";
	setAttr -s 9 ".lnk";
	setAttr -s 9 ".slnk";
createNode displayLayerManager -n "layerManager";
	rename -uid "87A55DEB-4461-F177-44DF-D098BD8C1010";
	setAttr ".cdl" 8;
	setAttr -s 9 ".dli[1:8]"  7 1 5 6 2 3 4 8;
	setAttr -s 7 ".dli";
createNode displayLayer -n "defaultLayer";
	rename -uid "172CC44B-44FB-540F-4CB3-17A98150D109";
createNode renderLayerManager -n "renderLayerManager";
	rename -uid "67307D72-49BD-69F4-1D8D-79B161EFBAF9";
createNode renderLayer -n "defaultRenderLayer";
	rename -uid "9822DFE0-40D6-EEB4-2854-74AEAF18C7B3";
	setAttr ".g" yes;
createNode script -n "uiConfigurationScriptNode";
	rename -uid "A24FB7FB-44BA-B900-E06B-E29199908AAC";
	setAttr ".b" -type "string" (
		"// Maya Mel UI Configuration File.\n//\n//  This script is machine generated.  Edit at your own risk.\n//\n//\n\nglobal string $gMainPane;\nif (`paneLayout -exists $gMainPane`) {\n\n\tglobal int $gUseScenePanelConfig;\n\tint    $useSceneConfig = $gUseScenePanelConfig;\n\tint    $menusOkayInPanels = `optionVar -q allowMenusInPanels`;\tint    $nVisPanes = `paneLayout -q -nvp $gMainPane`;\n\tint    $nPanes = 0;\n\tstring $editorName;\n\tstring $panelName;\n\tstring $itemFilterName;\n\tstring $panelConfig;\n\n\t//\n\t//  get current state of the UI\n\t//\n\tsceneUIReplacement -update $gMainPane;\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Top View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Top View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -docTag \"RADRENDER\" \n            -editorChanged \"DCF_updateViewportList;updateModelPanelBar\" \n            -camera \"front\" \n            -useInteractiveMode 0\n"
		+ "            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 1\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 1\n            -jointXray 0\n            -activeComponentsXray 0\n            -displayTextures 1\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n"
		+ "            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n"
		+ "            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1\n            -height 1\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Side View\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Side View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -docTag \"RADRENDER\" \n            -editorChanged \"DCF_updateViewportList;updateModelPanelBar\" \n            -camera \"back\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 1\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 1\n            -jointXray 0\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n"
		+ "            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n"
		+ "            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1\n            -height 1\n"
		+ "            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Front View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Front View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -docTag \"RADRENDER\" \n            -editorChanged \"DCF_updateViewportList;updateModelPanelBar\" \n            -camera \"side\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 1\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n"
		+ "            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 1\n            -jointXray 0\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n"
		+ "            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n"
		+ "            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1\n            -height 1\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Persp View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Persp View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -editorChanged \"DCF_updateViewportList;updateModelPanelBar\" \n"
		+ "            -camera \"persp\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 1\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 1\n            -jointXray 1\n            -activeComponentsXray 0\n            -displayTextures 1\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n"
		+ "            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n"
		+ "            -imagePlane 1\n            -joints 1\n            -ikHandles 0\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1385\n            -height 756\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"outlinerPanel\" (localizedPanelLabel(\"ToggledOutliner\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\toutlinerPanel -edit -l (localizedPanelLabel(\"ToggledOutliner\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        outlinerEditor -e \n            -showShapes 0\n            -showAssignedMaterials 0\n            -showTimeEditor 1\n            -showReferenceNodes 1\n            -showReferenceMembers 1\n            -showAttributes 0\n            -showConnected 0\n            -showAnimCurvesOnly 0\n            -showMuteInfo 0\n            -organizeByLayer 1\n            -organizeByClip 1\n            -showAnimLayerWeight 1\n            -autoExpandLayers 1\n            -autoExpand 0\n            -showDagOnly 1\n            -showAssets 1\n            -showContainedOnly 1\n            -showPublishedAsConnected 0\n            -showParentContainers 0\n            -showContainerContents 1\n            -ignoreDagHierarchy 0\n            -expandConnections 0\n            -showUpstreamCurves 1\n            -showUnitlessCurves 1\n            -showCompounds 1\n"
		+ "            -showLeafs 1\n            -showNumericAttrsOnly 0\n            -highlightActive 1\n            -autoSelectNewObjects 0\n            -doNotSelectNewObjects 0\n            -dropIsParent 1\n            -transmitFilters 0\n            -setFilter \"defaultSetFilter\" \n            -showSetMembers 1\n            -allowMultiSelection 1\n            -alwaysToggleSelect 0\n            -directSelect 0\n            -isSet 0\n            -isSetMember 0\n            -displayMode \"DAG\" \n            -expandObjects 0\n            -setsIgnoreFilters 1\n            -containersIgnoreFilters 0\n            -editAttrName 0\n            -showAttrValues 0\n            -highlightSecondary 0\n            -showUVAttrsOnly 0\n            -showTextureNodesOnly 0\n            -attrAlphaOrder \"default\" \n            -animLayerFilterOptions \"allAffecting\" \n            -sortOrder \"none\" \n            -longNames 0\n            -niceNames 1\n            -showNamespace 1\n            -showPinIcons 0\n            -mapMotionTrails 0\n            -ignoreHiddenAttribute 0\n"
		+ "            -ignoreOutlinerColor 0\n            -renderFilterVisible 0\n            -renderFilterIndex 0\n            -selectionOrder \"chronological\" \n            -expandAttribute 0\n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"outlinerPanel\" (localizedPanelLabel(\"Outliner\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\toutlinerPanel -edit -l (localizedPanelLabel(\"Outliner\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        outlinerEditor -e \n            -docTag \"isolOutln_fromSeln\" \n            -showShapes 0\n            -showAssignedMaterials 0\n            -showTimeEditor 1\n            -showReferenceNodes 0\n            -showReferenceMembers 0\n            -showAttributes 0\n            -showConnected 0\n            -showAnimCurvesOnly 0\n            -showMuteInfo 0\n            -organizeByLayer 1\n            -organizeByClip 1\n            -showAnimLayerWeight 1\n            -autoExpandLayers 1\n"
		+ "            -autoExpand 0\n            -showDagOnly 1\n            -showAssets 1\n            -showContainedOnly 1\n            -showPublishedAsConnected 0\n            -showParentContainers 0\n            -showContainerContents 1\n            -ignoreDagHierarchy 0\n            -expandConnections 0\n            -showUpstreamCurves 1\n            -showUnitlessCurves 1\n            -showCompounds 1\n            -showLeafs 1\n            -showNumericAttrsOnly 0\n            -highlightActive 1\n            -autoSelectNewObjects 0\n            -doNotSelectNewObjects 0\n            -dropIsParent 1\n            -transmitFilters 0\n            -setFilter \"defaultSetFilter\" \n            -showSetMembers 0\n            -allowMultiSelection 1\n            -alwaysToggleSelect 0\n            -directSelect 0\n            -displayMode \"DAG\" \n            -expandObjects 0\n            -setsIgnoreFilters 1\n            -containersIgnoreFilters 0\n            -editAttrName 0\n            -showAttrValues 0\n            -highlightSecondary 0\n            -showUVAttrsOnly 0\n"
		+ "            -showTextureNodesOnly 0\n            -attrAlphaOrder \"default\" \n            -animLayerFilterOptions \"allAffecting\" \n            -sortOrder \"none\" \n            -longNames 0\n            -niceNames 1\n            -showNamespace 0\n            -showPinIcons 0\n            -mapMotionTrails 0\n            -ignoreHiddenAttribute 0\n            -ignoreOutlinerColor 0\n            -renderFilterVisible 0\n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"graphEditor\" (localizedPanelLabel(\"Graph Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Graph Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"OutlineEd\");\n            outlinerEditor -e \n                -showShapes 1\n                -showAssignedMaterials 0\n                -showTimeEditor 1\n                -showReferenceNodes 0\n                -showReferenceMembers 0\n"
		+ "                -showAttributes 1\n                -showConnected 1\n                -showAnimCurvesOnly 1\n                -showMuteInfo 0\n                -organizeByLayer 1\n                -organizeByClip 1\n                -showAnimLayerWeight 1\n                -autoExpandLayers 1\n                -autoExpand 1\n                -showDagOnly 0\n                -showAssets 1\n                -showContainedOnly 0\n                -showPublishedAsConnected 0\n                -showParentContainers 1\n                -showContainerContents 0\n                -ignoreDagHierarchy 0\n                -expandConnections 1\n                -showUpstreamCurves 1\n                -showUnitlessCurves 1\n                -showCompounds 0\n                -showLeafs 1\n                -showNumericAttrsOnly 1\n                -highlightActive 0\n                -autoSelectNewObjects 1\n                -doNotSelectNewObjects 0\n                -dropIsParent 1\n                -transmitFilters 1\n                -setFilter \"0\" \n                -showSetMembers 0\n"
		+ "                -allowMultiSelection 1\n                -alwaysToggleSelect 0\n                -directSelect 0\n                -displayMode \"DAG\" \n                -expandObjects 0\n                -setsIgnoreFilters 1\n                -containersIgnoreFilters 0\n                -editAttrName 0\n                -showAttrValues 0\n                -highlightSecondary 0\n                -showUVAttrsOnly 0\n                -showTextureNodesOnly 0\n                -attrAlphaOrder \"default\" \n                -animLayerFilterOptions \"allAffecting\" \n                -sortOrder \"none\" \n                -longNames 0\n                -niceNames 1\n                -showNamespace 1\n                -showPinIcons 1\n                -mapMotionTrails 1\n                -ignoreHiddenAttribute 0\n                -ignoreOutlinerColor 0\n                -renderFilterVisible 0\n                $editorName;\n\n\t\t\t$editorName = ($panelName+\"GraphEd\");\n            animCurveEditor -e \n                -displayKeys 1\n                -displayTangents 0\n                -displayActiveKeys 0\n"
		+ "                -displayActiveKeyTangents 1\n                -displayInfinities 0\n                -displayValues 0\n                -autoFit 1\n                -snapTime \"integer\" \n                -snapValue \"none\" \n                -showResults \"off\" \n                -showBufferCurves \"off\" \n                -smoothness \"fine\" \n                -resultSamples 1.25\n                -resultScreenSamples 0\n                -resultUpdate \"delayed\" \n                -showUpstreamCurves 1\n                -showCurveNames 0\n                -showActiveCurveNames 0\n                -stackedCurves 0\n                -stackedCurvesMin -1\n                -stackedCurvesMax 1\n                -stackedCurvesSpace 0.2\n                -displayNormalized 0\n                -preSelectionHighlight 0\n                -constrainDrag 0\n                -classicMode 1\n                -valueLinesToggle 1\n                -outliner \"graphEditor1OutlineEd\" \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n"
		+ "\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dopeSheetPanel\" (localizedPanelLabel(\"Dope Sheet\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Dope Sheet\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"OutlineEd\");\n            outlinerEditor -e \n                -showShapes 1\n                -showAssignedMaterials 0\n                -showTimeEditor 1\n                -showReferenceNodes 0\n                -showReferenceMembers 0\n                -showAttributes 1\n                -showConnected 1\n                -showAnimCurvesOnly 1\n                -showMuteInfo 0\n                -organizeByLayer 1\n                -organizeByClip 1\n                -showAnimLayerWeight 1\n                -autoExpandLayers 1\n                -autoExpand 0\n                -showDagOnly 0\n                -showAssets 1\n                -showContainedOnly 0\n                -showPublishedAsConnected 0\n                -showParentContainers 1\n"
		+ "                -showContainerContents 0\n                -ignoreDagHierarchy 0\n                -expandConnections 1\n                -showUpstreamCurves 1\n                -showUnitlessCurves 0\n                -showCompounds 1\n                -showLeafs 1\n                -showNumericAttrsOnly 1\n                -highlightActive 0\n                -autoSelectNewObjects 0\n                -doNotSelectNewObjects 1\n                -dropIsParent 1\n                -transmitFilters 0\n                -setFilter \"0\" \n                -showSetMembers 0\n                -allowMultiSelection 1\n                -alwaysToggleSelect 0\n                -directSelect 0\n                -displayMode \"DAG\" \n                -expandObjects 0\n                -setsIgnoreFilters 1\n                -containersIgnoreFilters 0\n                -editAttrName 0\n                -showAttrValues 0\n                -highlightSecondary 0\n                -showUVAttrsOnly 0\n                -showTextureNodesOnly 0\n                -attrAlphaOrder \"default\" \n                -animLayerFilterOptions \"allAffecting\" \n"
		+ "                -sortOrder \"none\" \n                -longNames 0\n                -niceNames 1\n                -showNamespace 1\n                -showPinIcons 0\n                -mapMotionTrails 1\n                -ignoreHiddenAttribute 0\n                -ignoreOutlinerColor 0\n                -renderFilterVisible 0\n                $editorName;\n\n\t\t\t$editorName = ($panelName+\"DopeSheetEd\");\n            dopeSheetEditor -e \n                -displayKeys 1\n                -displayTangents 0\n                -displayActiveKeys 0\n                -displayActiveKeyTangents 0\n                -displayInfinities 0\n                -displayValues 0\n                -autoFit 0\n                -snapTime \"integer\" \n                -snapValue \"none\" \n                -outliner \"dopeSheetPanel1OutlineEd\" \n                -showSummary 1\n                -showScene 0\n                -hierarchyBelow 0\n                -showTicks 1\n                -selectionWindow 0 0 0 0 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n"
		+ "\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"timeEditorPanel\" (localizedPanelLabel(\"Time Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Time Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"clipEditorPanel\" (localizedPanelLabel(\"Trax Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Trax Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = clipEditorNameFromPanel($panelName);\n            clipEditor -e \n                -displayKeys 0\n                -displayTangents 0\n                -displayActiveKeys 0\n                -displayActiveKeyTangents 0\n                -displayInfinities 0\n                -displayValues 0\n                -autoFit 0\n                -snapTime \"none\" \n                -snapValue \"none\" \n"
		+ "                -initialized 0\n                -manageSequencer 0 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"sequenceEditorPanel\" (localizedPanelLabel(\"Camera Sequencer\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Camera Sequencer\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = sequenceEditorNameFromPanel($panelName);\n            clipEditor -e \n                -displayKeys 0\n                -displayTangents 0\n                -displayActiveKeys 0\n                -displayActiveKeyTangents 0\n                -displayInfinities 0\n                -displayValues 0\n                -autoFit 0\n                -snapTime \"none\" \n                -snapValue \"none\" \n                -initialized 0\n                -manageSequencer 1 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"hyperGraphPanel\" (localizedPanelLabel(\"Hypergraph Hierarchy\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Hypergraph Hierarchy\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"HyperGraphEd\");\n            hyperGraph -e \n                -graphLayoutStyle \"hierarchicalLayout\" \n                -orientation \"horiz\" \n                -mergeConnections 0\n                -zoom 1\n                -animateTransition 0\n                -showRelationships 1\n                -showShapes 0\n                -showDeformers 0\n                -showExpressions 0\n                -showConstraints 0\n                -showConnectionFromSelected 0\n                -showConnectionToSelected 0\n                -showConstraintLabels 0\n                -showUnderworld 0\n                -showInvisible 0\n                -transitionFrames 1\n                -opaqueContainers 0\n                -freeform 0\n                -image \"T:/Maya_Tak/data/TK_Test_1032_Sc007_v01_DQ_retake_01.ma_TK_Tak_hairSystem_Tak__HairShape.mchp\" \n"
		+ "                -imagePosition 0 0 \n                -imageScale 1\n                -imageEnabled 0\n                -graphType \"DAG\" \n                -heatMapDisplay 0\n                -updateSelection 1\n                -updateNodeAdded 1\n                -useDrawOverrideColor 0\n                -limitGraphTraversal -1\n                -range 0 0 \n                -iconSize \"smallIcons\" \n                -showCachedConnections 0\n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"hyperShadePanel\" (localizedPanelLabel(\"Hypershade\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Hypershade\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"visorPanel\" (localizedPanelLabel(\"Visor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n"
		+ "\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Visor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"createNodePanel\" (localizedPanelLabel(\"Create Node\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Create Node\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"polyTexturePlacementPanel\" (localizedPanelLabel(\"UV Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"UV Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"renderWindowPanel\" (localizedPanelLabel(\"Render View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n"
		+ "\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Render View\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"shapePanel\" (localizedPanelLabel(\"Shape Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tshapePanel -edit -l (localizedPanelLabel(\"Shape Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"posePanel\" (localizedPanelLabel(\"Pose Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tposePanel -edit -l (localizedPanelLabel(\"Pose Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dynRelEdPanel\" (localizedPanelLabel(\"Dynamic Relationships\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Dynamic Relationships\")) -mbv $menusOkayInPanels  $panelName;\n"
		+ "\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"relationshipPanel\" (localizedPanelLabel(\"Relationship Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Relationship Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"referenceEditorPanel\" (localizedPanelLabel(\"Reference Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Reference Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"componentEditorPanel\" (localizedPanelLabel(\"Component Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Component Editor\")) -mbv $menusOkayInPanels  $panelName;\n"
		+ "\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dynPaintScriptedPanelType\" (localizedPanelLabel(\"Paint Effects\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Paint Effects\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"scriptEditorPanel\" (localizedPanelLabel(\"Script Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Script Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"profilerPanel\" (localizedPanelLabel(\"Profiler Tool\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Profiler Tool\")) -mbv $menusOkayInPanels  $panelName;\n"
		+ "\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"contentBrowserPanel\" (localizedPanelLabel(\"Content Browser\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Content Browser\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"Stereo\" (localizedPanelLabel(\"Stereo\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Stereo\")) -mbv $menusOkayInPanels  $panelName;\nstring $editorName = ($panelName+\"Editor\");\n            stereoCameraView -e \n                -editorChanged \"updateModelPanelBar\" \n                -camera \"persp\" \n                -useInteractiveMode 0\n                -displayLights \"default\" \n                -displayAppearance \"smoothShaded\" \n                -activeOnly 0\n                -ignorePanZoom 0\n"
		+ "                -wireframeOnShaded 0\n                -headsUpDisplay 1\n                -holdOuts 1\n                -selectionHiliteDisplay 1\n                -useDefaultMaterial 0\n                -bufferMode \"double\" \n                -twoSidedLighting 0\n                -backfaceCulling 0\n                -xray 0\n                -jointXray 0\n                -activeComponentsXray 0\n                -displayTextures 0\n                -smoothWireframe 0\n                -lineWidth 1\n                -textureAnisotropic 0\n                -textureHilight 1\n                -textureSampling 2\n                -textureDisplay \"modulate\" \n                -textureMaxSize 32768\n                -fogging 0\n                -fogSource \"fragment\" \n                -fogMode \"linear\" \n                -fogStart 0\n                -fogEnd 100\n                -fogDensity 0.1\n                -fogColor 0.5 0.5 0.5 1 \n                -depthOfFieldPreview 1\n                -maxConstantTransparency 1\n                -rendererOverrideName \"stereoOverrideVP2\" \n"
		+ "                -objectFilterShowInHUD 1\n                -isFiltered 0\n                -colorResolution 4 4 \n                -bumpResolution 4 4 \n                -textureCompression 0\n                -transparencyAlgorithm \"frontAndBackCull\" \n                -transpInShadows 0\n                -cullingOverride \"none\" \n                -lowQualityLighting 0\n                -maximumNumHardwareLights 0\n                -occlusionCulling 0\n                -shadingModel 0\n                -useBaseRenderer 0\n                -useReducedRenderer 0\n                -smallObjectCulling 0\n                -smallObjectThreshold -1 \n                -interactiveDisableShadows 0\n                -interactiveBackFaceCull 0\n                -sortTransparent 1\n                -controllers 1\n                -nurbsCurves 1\n                -nurbsSurfaces 1\n                -polymeshes 1\n                -subdivSurfaces 1\n                -planes 1\n                -lights 1\n                -cameras 1\n                -controlVertices 1\n                -hulls 1\n"
		+ "                -grid 1\n                -imagePlane 1\n                -joints 1\n                -ikHandles 1\n                -deformers 1\n                -dynamics 1\n                -particleInstancers 1\n                -fluids 1\n                -hairSystems 1\n                -follicles 1\n                -nCloths 1\n                -nParticles 1\n                -nRigids 1\n                -dynamicConstraints 1\n                -locators 1\n                -manipulators 1\n                -pluginShapes 1\n                -dimensions 1\n                -handles 1\n                -pivots 1\n                -textures 1\n                -strokes 1\n                -motionTrails 1\n                -clipGhosts 1\n                -greasePencils 1\n                -shadows 0\n                -captureSequenceNumber -1\n                -width 0\n                -height 0\n                -sceneRenderFilter 0\n                -displayMode \"centerEye\" \n                -viewColor 0 0 0 1 \n                -useCustomBackground 1\n                $editorName;\n"
		+ "            stereoCameraView -e -viewSelected 0 $editorName;\n            stereoCameraView -e \n                -pluginObjects \"gpuCacheDisplayFilter\" 1 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"nodeEditorPanel\" (localizedPanelLabel(\"Node Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Node Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"NodeEditorEd\");\n            nodeEditor -e \n                -allAttributes 0\n                -allNodes 0\n                -autoSizeNodes 1\n                -consistentNameSize 1\n                -createNodeCommand \"nodeEdCreateNodeCommand\" \n                -connectNodeOnCreation 0\n                -connectOnDrop 0\n                -highlightConnections 0\n                -copyConnectionsOnPaste 0\n                -defaultPinnedState 0\n                -additiveGraphingMode 0\n"
		+ "                -settingsChangedCallback \"nodeEdSyncControls\" \n                -traversalDepthLimit -1\n                -keyPressCommand \"nodeEdKeyPressCommand\" \n                -nodeTitleMode \"name\" \n                -gridSnap 0\n                -gridVisibility 1\n                -crosshairOnEdgeDragging 0\n                -popupMenuScript \"nodeEdBuildPanelMenus\" \n                -showNamespace 1\n                -showShapes 1\n                -showSGShapes 0\n                -showTransforms 1\n                -useAssets 1\n                -syncedSelection 1\n                -extendToShapes 1\n                -activeTab -1\n                -editorMode \"default\" \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\tif ($useSceneConfig) {\n        string $configName = `getPanel -cwl (localizedPanelLabel(\"Current Layout\"))`;\n        if (\"\" != $configName) {\n\t\t\tpanelConfiguration -edit -label (localizedPanelLabel(\"Current Layout\")) \n\t\t\t\t-userCreated false\n\t\t\t\t-defaultImage \"vacantCell.xP:/\"\n"
		+ "\t\t\t\t-image \"\"\n\t\t\t\t-sc false\n\t\t\t\t-configString \"global string $gMainPane; paneLayout -e -cn \\\"single\\\" -ps 1 100 100 $gMainPane;\"\n\t\t\t\t-removeAllPanels\n\t\t\t\t-ap false\n\t\t\t\t\t(localizedPanelLabel(\"Persp View\")) \n\t\t\t\t\t\"modelPanel\"\n"
		+ "\t\t\t\t\t\"$panelName = `modelPanel -unParent -l (localizedPanelLabel(\\\"Persp View\\\")) -mbv $menusOkayInPanels `;\\n$editorName = $panelName;\\nmodelEditor -e \\n    -editorChanged \\\"DCF_updateViewportList;updateModelPanelBar\\\" \\n    -cam `findStartUpCamera persp` \\n    -useInteractiveMode 0\\n    -displayLights \\\"default\\\" \\n    -displayAppearance \\\"smoothShaded\\\" \\n    -activeOnly 0\\n    -ignorePanZoom 0\\n    -wireframeOnShaded 1\\n    -headsUpDisplay 1\\n    -holdOuts 1\\n    -selectionHiliteDisplay 1\\n    -useDefaultMaterial 0\\n    -bufferMode \\\"double\\\" \\n    -twoSidedLighting 0\\n    -backfaceCulling 0\\n    -xray 1\\n    -jointXray 1\\n    -activeComponentsXray 0\\n    -displayTextures 1\\n    -smoothWireframe 0\\n    -lineWidth 1\\n    -textureAnisotropic 0\\n    -textureHilight 1\\n    -textureSampling 2\\n    -textureDisplay \\\"modulate\\\" \\n    -textureMaxSize 32768\\n    -fogging 0\\n    -fogSource \\\"fragment\\\" \\n    -fogMode \\\"linear\\\" \\n    -fogStart 0\\n    -fogEnd 100\\n    -fogDensity 0.1\\n    -fogColor 0.5 0.5 0.5 1 \\n    -depthOfFieldPreview 1\\n    -maxConstantTransparency 1\\n    -rendererName \\\"vp2Renderer\\\" \\n    -objectFilterShowInHUD 1\\n    -isFiltered 0\\n    -colorResolution 256 256 \\n    -bumpResolution 512 512 \\n    -textureCompression 0\\n    -transparencyAlgorithm \\\"frontAndBackCull\\\" \\n    -transpInShadows 0\\n    -cullingOverride \\\"none\\\" \\n    -lowQualityLighting 0\\n    -maximumNumHardwareLights 1\\n    -occlusionCulling 0\\n    -shadingModel 0\\n    -useBaseRenderer 0\\n    -useReducedRenderer 0\\n    -smallObjectCulling 0\\n    -smallObjectThreshold -1 \\n    -interactiveDisableShadows 0\\n    -interactiveBackFaceCull 0\\n    -sortTransparent 1\\n    -controllers 1\\n    -nurbsCurves 1\\n    -nurbsSurfaces 1\\n    -polymeshes 1\\n    -subdivSurfaces 1\\n    -planes 1\\n    -lights 1\\n    -cameras 1\\n    -controlVertices 1\\n    -hulls 1\\n    -grid 1\\n    -imagePlane 1\\n    -joints 1\\n    -ikHandles 0\\n    -deformers 1\\n    -dynamics 1\\n    -particleInstancers 1\\n    -fluids 1\\n    -hairSystems 1\\n    -follicles 1\\n    -nCloths 1\\n    -nParticles 1\\n    -nRigids 1\\n    -dynamicConstraints 1\\n    -locators 1\\n    -manipulators 1\\n    -pluginShapes 1\\n    -dimensions 1\\n    -handles 1\\n    -pivots 1\\n    -textures 1\\n    -strokes 1\\n    -motionTrails 1\\n    -clipGhosts 1\\n    -greasePencils 1\\n    -shadows 0\\n    -captureSequenceNumber -1\\n    -width 1385\\n    -height 756\\n    -sceneRenderFilter 0\\n    $editorName;\\nmodelEditor -e -viewSelected 0 $editorName;\\nmodelEditor -e \\n    -pluginObjects \\\"gpuCacheDisplayFilter\\\" 1 \\n    $editorName\"\n"
		+ "\t\t\t\t\t\"modelPanel -edit -l (localizedPanelLabel(\\\"Persp View\\\")) -mbv $menusOkayInPanels  $panelName;\\n$editorName = $panelName;\\nmodelEditor -e \\n    -editorChanged \\\"DCF_updateViewportList;updateModelPanelBar\\\" \\n    -cam `findStartUpCamera persp` \\n    -useInteractiveMode 0\\n    -displayLights \\\"default\\\" \\n    -displayAppearance \\\"smoothShaded\\\" \\n    -activeOnly 0\\n    -ignorePanZoom 0\\n    -wireframeOnShaded 1\\n    -headsUpDisplay 1\\n    -holdOuts 1\\n    -selectionHiliteDisplay 1\\n    -useDefaultMaterial 0\\n    -bufferMode \\\"double\\\" \\n    -twoSidedLighting 0\\n    -backfaceCulling 0\\n    -xray 1\\n    -jointXray 1\\n    -activeComponentsXray 0\\n    -displayTextures 1\\n    -smoothWireframe 0\\n    -lineWidth 1\\n    -textureAnisotropic 0\\n    -textureHilight 1\\n    -textureSampling 2\\n    -textureDisplay \\\"modulate\\\" \\n    -textureMaxSize 32768\\n    -fogging 0\\n    -fogSource \\\"fragment\\\" \\n    -fogMode \\\"linear\\\" \\n    -fogStart 0\\n    -fogEnd 100\\n    -fogDensity 0.1\\n    -fogColor 0.5 0.5 0.5 1 \\n    -depthOfFieldPreview 1\\n    -maxConstantTransparency 1\\n    -rendererName \\\"vp2Renderer\\\" \\n    -objectFilterShowInHUD 1\\n    -isFiltered 0\\n    -colorResolution 256 256 \\n    -bumpResolution 512 512 \\n    -textureCompression 0\\n    -transparencyAlgorithm \\\"frontAndBackCull\\\" \\n    -transpInShadows 0\\n    -cullingOverride \\\"none\\\" \\n    -lowQualityLighting 0\\n    -maximumNumHardwareLights 1\\n    -occlusionCulling 0\\n    -shadingModel 0\\n    -useBaseRenderer 0\\n    -useReducedRenderer 0\\n    -smallObjectCulling 0\\n    -smallObjectThreshold -1 \\n    -interactiveDisableShadows 0\\n    -interactiveBackFaceCull 0\\n    -sortTransparent 1\\n    -controllers 1\\n    -nurbsCurves 1\\n    -nurbsSurfaces 1\\n    -polymeshes 1\\n    -subdivSurfaces 1\\n    -planes 1\\n    -lights 1\\n    -cameras 1\\n    -controlVertices 1\\n    -hulls 1\\n    -grid 1\\n    -imagePlane 1\\n    -joints 1\\n    -ikHandles 0\\n    -deformers 1\\n    -dynamics 1\\n    -particleInstancers 1\\n    -fluids 1\\n    -hairSystems 1\\n    -follicles 1\\n    -nCloths 1\\n    -nParticles 1\\n    -nRigids 1\\n    -dynamicConstraints 1\\n    -locators 1\\n    -manipulators 1\\n    -pluginShapes 1\\n    -dimensions 1\\n    -handles 1\\n    -pivots 1\\n    -textures 1\\n    -strokes 1\\n    -motionTrails 1\\n    -clipGhosts 1\\n    -greasePencils 1\\n    -shadows 0\\n    -captureSequenceNumber -1\\n    -width 1385\\n    -height 756\\n    -sceneRenderFilter 0\\n    $editorName;\\nmodelEditor -e -viewSelected 0 $editorName;\\nmodelEditor -e \\n    -pluginObjects \\\"gpuCacheDisplayFilter\\\" 1 \\n    $editorName\"\n"
		+ "\t\t\t\t$configName;\n\n            setNamedPanelLayout (localizedPanelLabel(\"Current Layout\"));\n        }\n\n        panelHistory -e -clear mainPanelHistory;\n        sceneUIReplacement -clear;\n\t}\n\n\ngrid -spacing 5 -size 12 -divisions 5 -displayAxes yes -displayGridLines yes -displayDivisionLines yes -displayPerspectiveLabels no -displayOrthographicLabels no -displayAxesBold yes -perspectiveLabelPosition axis -orthographicLabelPosition edge;\nviewManip -drawCompass 0 -compassAngle 0 -frontParameters \"\" -homeParameters \"\" -selectionLockParameters \"\";\n}\n");
	setAttr ".st" 3;
createNode script -n "sceneConfigurationScriptNode";
	rename -uid "E4AAF8D4-47D5-A90D-B322-4A8B3D380C7D";
	setAttr ".b" -type "string" "playbackOptions -min 0 -max 100 -ast 0 -aet 100 ";
	setAttr ".st" 6;
createNode shadingEngine -n "catlow:Default";
	rename -uid "8C5A8881-4E75-9F5B-E248-58B62CEB79B4";
	setAttr ".ihi" 0;
	setAttr ".ro" yes;
createNode materialInfo -n "catlow:materialInfo1";
	rename -uid "FF53C391-4DF1-0172-4A6C-1E97DEABDD57";
createNode shapeEditorManager -n "shapeEditorManager";
	rename -uid "53CB914D-4E7D-A460-3826-1F838E19E73D";
createNode poseInterpolatorManager -n "poseInterpolatorManager";
	rename -uid "AE29EF87-478B-9A6E-4A2B-A7BBD79CD9BE";
createNode ilrOptionsNode -s -n "TurtleRenderOptions";
	rename -uid "10B52182-4F96-7A73-AC16-C6912BF13AEA";
lockNode -l 1 ;
createNode ilrUIOptionsNode -s -n "TurtleUIOptions";
	rename -uid "15877005-4431-A348-C7FE-7F95DDFF5BA5";
lockNode -l 1 ;
createNode ilrBakeLayerManager -s -n "TurtleBakeLayerManager";
	rename -uid "73BE68A6-42F6-5FCF-9822-91BFBC6C1C1F";
lockNode -l 1 ;
createNode ilrBakeLayer -s -n "TurtleDefaultBakeLayer";
	rename -uid "6B15408A-4751-C0EA-5108-66A68BDF5BED";
lockNode -l 1 ;
createNode groupId -n "catlow:groupId1";
	rename -uid "55CC743A-4AE8-F5C2-9332-51943ED2842D";
	setAttr ".ihi" 0;
createNode objectSet -n "catlow:catlow:set2";
	rename -uid "E5933A19-4BF7-6F54-06ED-609407A424FD";
	setAttr ".ihi" 0;
createNode shadingEngine -n "playerstartSG";
	rename -uid "A96AC4EB-48BB-18A3-8FC8-9BB411C702F7";
	setAttr ".ihi" 0;
	setAttr ".ro" yes;
createNode materialInfo -n "materialInfo1";
	rename -uid "CDA434A4-487F-B40F-2CF4-32BEE4242F5B";
createNode shadingEngine -n "playerstartSG1";
	rename -uid "4105B23B-42A5-86CB-D0F1-4B993A0DD11A";
	setAttr ".ihi" 0;
	setAttr ".ro" yes;
createNode materialInfo -n "materialInfo2";
	rename -uid "819C4BC0-4258-45AD-9B2C-A6AF41B5621E";
createNode file -n "EditorFBXASC047orangeFBXASC046vtf";
	rename -uid "808268F3-4BE3-F77E-FC00-12AA70179C88";
	setAttr ".ftn" -type "string" "e:\\black mesa\\hl2\\materials\\editor\\orange.vtf";
	setAttr ".cs" -type "string" "sRGB";
createNode place2dTexture -n "place2dTexture1";
	rename -uid "50E63BCA-4461-72D4-7552-208F813FAE2B";
createNode file -n "EditorFBXASC047grayFBXASC046vtf";
	rename -uid "FBA96706-4DB7-6C30-8A14-23A458C0B43D";
	setAttr ".ftn" -type "string" "e:\\black mesa\\hl2\\materials\\editor\\gray.vtf";
	setAttr ".cs" -type "string" "sRGB";
createNode place2dTexture -n "place2dTexture2";
	rename -uid "3E1DD56D-4C02-7149-0AEE-208345106068";
createNode groupId -n "groupId15";
	rename -uid "281C0AE1-4880-C058-6C5E-07BBDFFA17DE";
	setAttr ".ihi" 0;
createNode groupId -n "groupId16";
	rename -uid "7513096A-42AB-C298-8E28-F18F0A176BD3";
	setAttr ".ihi" 0;
createNode groupId -n "groupId17";
	rename -uid "A2C991F1-4493-6EC4-463B-4EB8211FDC89";
	setAttr ".ihi" 0;
createNode ikSplineSolver -n "ikSplineSolver";
	rename -uid "78644120-4FCC-18FB-1932-F881FC0B3600";
createNode skinCluster -n "skinCluster1";
	rename -uid "E7DAA15E-45C7-70D7-C978-EBAB97CA2DFC";
	setAttr -s 5 ".wl";
	setAttr ".wl[0:4].w"
		1 1 1
		2 0 0.0016087512042249556 1 0.99839124879577501
		2 0 0.49779272691147852 1 0.50220727308852142
		2 0 0.99840609238582523 1 0.0015939076141747767
		1 0 1;
	setAttr -s 2 ".pm";
	setAttr ".pm[0]" -type "matrix" -0.029642150543423538 0.99956057490484629 2.6559138760693908e-06 0
		 3.5266866018800391e-05 -1.6112361401525144e-06 0.99999999937682604 0 0.99956057428622558 0.029642150618617209 -3.5203608368547544e-05 0
		 -54.499564270812911 -3.0134697273852309 0.0021591788265737282 1;
	setAttr ".pm[1]" -type "matrix" 0.17807765569036313 0.98401643713032616 -1.0785164665625895e-06 0
		 -4.2108128786749368e-09 1.0967970427528644e-06 0.99999999999939815 0 0.98401643713091713 -0.17807765569025133 1.9945855526737843e-07 0
		 -23.574007696116553 3.472889784087414 0.00023814704477321961 1;
	setAttr ".gm" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr -s 2 ".ma";
	setAttr -s 2 ".dpf[0:1]"  4 4;
	setAttr -s 2 ".lw";
	setAttr -s 2 ".lw";
	setAttr ".mmi" yes;
	setAttr ".mi" 5;
	setAttr ".ucm" yes;
	setAttr -s 2 ".ifcl";
	setAttr -s 2 ".ifcl";
createNode tweak -n "tweak1";
	rename -uid "969B942E-47A6-1C88-084B-E9B99E0330CE";
createNode objectSet -n "skinCluster1Set";
	rename -uid "3861F6C4-4661-3D70-9E4D-4AA60AAC4392";
	setAttr ".ihi" 0;
	setAttr ".vo" yes;
createNode groupId -n "skinCluster1GroupId";
	rename -uid "1B9C0FC0-4AE8-4255-0A7D-E99FA9EE2D8B";
	setAttr ".ihi" 0;
createNode groupParts -n "skinCluster1GroupParts";
	rename -uid "3FF2B6CB-4052-FB76-7317-81A5071F4797";
	setAttr ".ihi" 0;
	setAttr ".ic" -type "componentList" 1 "cv[*]";
createNode objectSet -n "tweakSet1";
	rename -uid "5F0DABA7-464B-2771-AE4C-1F9ADEE6E69A";
	setAttr ".ihi" 0;
	setAttr ".vo" yes;
createNode groupId -n "groupId55";
	rename -uid "8C965527-46C1-4FFF-304D-2FAC77FA2EE4";
	setAttr ".ihi" 0;
createNode groupParts -n "groupParts2";
	rename -uid "AC356F4B-4F6D-64A1-3987-32918B1EA4DD";
	setAttr ".ihi" 0;
	setAttr ".ic" -type "componentList" 1 "cv[*]";
createNode dagPose -n "bindPose1";
	rename -uid "2EE98903-4EE4-AEB8-AC4E-1CA75F2F2226";
	setAttr -s 2 ".wm";
	setAttr -s 2 ".xm";
	setAttr ".xm[0]" -type "matrix" "xform" 1 1 1 0 0 0 0 1.396661238762509 -0.0002420054053424119
		 54.564941560437511 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0.49254306012294119 0.50736469696748998 0.50734814431788233 -0.49252437366389989 1
		 1 1 yes;
	setAttr ".xm[1]" -type "matrix" "xform" 1 1 1 8.0830269136346042e-12 -4.2108129359908852e-09
		 -0.0038391717268150753 0 0.78062339412385251 -0.00024205536575423349 23.815655133202849 0
		 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -0.54356527801808319 -0.45225732587084355 -0.45225682983296245 0.54356587420359315 1
		 1 1 yes;
	setAttr -s 2 ".m";
	setAttr -s 2 ".p";
	setAttr ".bp" yes;
createNode groupId -n "groupId59";
	rename -uid "59A1CA48-40CE-C95B-C919-3CA548A78D37";
	setAttr ".ihi" 0;
createNode groupId -n "groupId60";
	rename -uid "A49A8AC9-4067-CF9E-44A3-C9BEB31EBD57";
	setAttr ".ihi" 0;
createNode curveInfo -n "spine_curveInfo";
	rename -uid "9BA60926-4652-5324-E4E5-F7B963F69E3E";
createNode plusMinusAverage -n "plusMinusAverage1";
	rename -uid "E37B0858-4FAF-0377-365E-49B6F8F910F6";
	setAttr ".op" 2;
	setAttr -s 2 ".i1[1]"  31.00053787231;
createNode multiplyDivide -n "multiplyDivide1";
	rename -uid "977A2722-417E-736C-13CA-F6AA10531A2C";
	setAttr ".op" 2;
	setAttr ".i2" -type "float3" 3 1 1 ;
createNode plusMinusAverage -n "spine_03_plus";
	rename -uid "5455F404-41EA-5CAF-5A96-6985AC621AE2";
	setAttr -s 2 ".i1[1]"  11.32400036;
createNode plusMinusAverage -n "spine_01_plus";
	rename -uid "22904A94-40A2-8ECE-5CB6-98A05104999A";
	setAttr -s 2 ".i1[1]"  8.56499958;
createNode plusMinusAverage -n "spine_02_plus";
	rename -uid "58A5599D-43D5-4AF1-5A89-B49991206A21";
	setAttr -s 2 ".i1[1]"  11.088999748;
createNode makeNurbCircle -n "makeNurbCircle1";
	rename -uid "8B6B679C-41FB-0F8D-9AD6-209E651011DE";
	setAttr ".nr" -type "double3" 1 0 0 ;
	setAttr ".r" 30;
createNode groupId -n "groupId65";
	rename -uid "1EB0437E-44EF-4285-6F13-75BDF5F4B93C";
	setAttr ".ihi" 0;
createNode groupId -n "groupId66";
	rename -uid "8F0F6A40-415D-DF72-CD2F-BAAE99F84DD9";
	setAttr ".ihi" 0;
createNode ikRPsolver -n "ikRPsolver";
	rename -uid "EE5A6FB1-4F77-1BE7-545C-6394146554E6";
createNode reverse -n "rev_head_const";
	rename -uid "5C172F3C-414B-85CA-0A07-B59F3A5CE8AE";
createNode animCurveTU -n "ctrl_tail_01_blendParent1";
	rename -uid "E0C26CCE-41A0-548E-20C3-A5878B6735BB";
	setAttr ".tan" 18;
	setAttr ".wgt" no;
	setAttr ".ktv[0]"  1 0;
createNode surfaceShader -n "surfaceShader1";
	rename -uid "7617FCE5-464E-1134-12DB-2095A517966B";
	setAttr ".oc" -type "float3" 0.33333334 0.25416753 0 ;
	setAttr ".ot" -type "float3" 0.84090906 0.84090906 0.84090906 ;
	setAttr ".omo" -type "float3" 0 0 0 ;
createNode shadingEngine -n "surfaceShader1SG";
	rename -uid "E0368245-47E0-539A-CFEC-E28834170739";
	setAttr ".ihi" 0;
	setAttr -s 7 ".dsm";
	setAttr ".ro" yes;
	setAttr -s 7 ".gn";
createNode materialInfo -n "materialInfo3";
	rename -uid "FE6A0AC1-41AA-9616-64C1-6F863A5F91B1";
createNode displayLayer -n "spine";
	rename -uid "DB35FF19-46C5-448B-DD6F-96BC6A9E4245";
	setAttr ".c" 17;
	setAttr ".do" 5;
createNode surfaceShader -n "surfaceShader2";
	rename -uid "D79D0768-4A94-7F91-648B-E5A6EC4C6B09";
	setAttr ".oc" -type "float3" 0.11727392 0.6098485 0 ;
	setAttr ".ot" -type "float3" 0.7651515 0.7651515 0.7651515 ;
createNode shadingEngine -n "surfaceShader2SG";
	rename -uid "8AD33211-4980-3D06-2747-33A506C58456";
	setAttr ".ihi" 0;
	setAttr -s 5 ".dsm";
	setAttr ".ro" yes;
createNode materialInfo -n "materialInfo4";
	rename -uid "4669888C-45DC-DE8B-0F94-46B6A9C1C357";
createNode displayLayer -n "tail";
	rename -uid "772F0C92-46A3-C11B-03FE-0FB13FF27DF5";
	setAttr ".c" 14;
	setAttr ".do" 7;
createNode displayLayer -n "left";
	rename -uid "92AF27CF-4C3B-CF0A-AC88-15BE90CAC4AE";
	setAttr ".c" 6;
	setAttr ".do" 8;
createNode displayLayer -n "head";
	rename -uid "7FB39232-4335-A04B-C5F8-5F8EE7C3A77D";
	setAttr ".c" 17;
	setAttr ".do" 6;
createNode surfaceShader -n "surfaceShader3";
	rename -uid "D00AA15B-4B65-9C0C-7B79-31938B49372D";
	setAttr ".oc" -type "float3" 0.038466454 0 1 ;
	setAttr ".ot" -type "float3" 0.61742425 0.61742425 0.61742425 ;
createNode shadingEngine -n "surfaceShader3SG";
	rename -uid "1A44D5CD-4A39-BC6D-FAAF-FC9022184055";
	setAttr ".ihi" 0;
	setAttr -s 7 ".dsm";
	setAttr ".ro" yes;
	setAttr -s 2 ".gn";
createNode materialInfo -n "materialInfo5";
	rename -uid "3143D868-4930-4BB8-E323-D5ACF0000619";
createNode displayLayer -n "right";
	rename -uid "1A1053B7-426C-1D1E-3833-8299819A91C6";
	setAttr ".c" 13;
	setAttr ".do" 10;
createNode surfaceShader -n "surfaceShader4";
	rename -uid "55A7D3B1-4C8E-8376-9292-EFB01293DC0E";
	setAttr ".oc" -type "float3" 1 0 0.16870022 ;
	setAttr ".ot" -type "float3" 0.58712119 0.58712119 0.58712119 ;
createNode shadingEngine -n "surfaceShader4SG";
	rename -uid "08C529AF-4470-55EE-CFC9-A595E4C8ED01";
	setAttr ".ihi" 0;
	setAttr -s 7 ".dsm";
	setAttr ".ro" yes;
	setAttr -s 2 ".gn";
createNode materialInfo -n "materialInfo6";
	rename -uid "9678212C-4BED-9B3D-3C5A-DA9C70BFD842";
createNode aiOptions -s -n "defaultArnoldRenderOptions";
	rename -uid "6E7CD44D-40CD-7A29-2FD5-17A06A813BF8";
	setAttr ".version" -type "string" "2.0.1";
createNode aiAOVFilter -s -n "defaultArnoldFilter";
	rename -uid "64946266-4BCB-2CB6-C4E0-E88F215BD05D";
createNode aiAOVDriver -s -n "defaultArnoldDriver";
	rename -uid "7A5DF693-4702-65EC-A4B2-1BACD3FF4F35";
createNode aiAOVDriver -s -n "defaultArnoldDisplayDriver";
	rename -uid "DD646A6D-4ECD-7A2E-8E75-2887DF074668";
	setAttr ".output_mode" 0;
	setAttr ".ai_translator" -type "string" "maya";
createNode makeNurbCircle -n "makeNurbCircle9";
	rename -uid "3DAB190F-40A3-9FAA-5761-1D9010AB72D6";
	setAttr ".nr" -type "double3" 0 1 0 ;
	setAttr ".r" 2;
createNode makeNurbCircle -n "makeNurbCircle10";
	rename -uid "171828D8-4B28-C5FE-3AEC-6E80119D0822";
	setAttr ".nr" -type "double3" 1 0 0 ;
	setAttr ".r" 2;
createNode makeNurbCircle -n "makeNurbCircle11";
	rename -uid "A4B83465-4794-5D23-1AB3-21848105D18B";
	setAttr ".r" 2;
createNode groupId -n "groupId75";
	rename -uid "F620F9AE-4112-0AA1-72AF-9BA7767B70E4";
	setAttr ".ihi" 0;
createNode groupId -n "groupId76";
	rename -uid "3690F6B7-46C8-81D8-0ECC-A5A3D47E108B";
	setAttr ".ihi" 0;
createNode groupId -n "groupId77";
	rename -uid "F70D551D-49D5-DFC3-848D-9E862221AFE7";
	setAttr ".ihi" 0;
createNode groupId -n "groupId78";
	rename -uid "B73618FF-4A18-CC83-0AE0-4C99407AECAA";
	setAttr ".ihi" 0;
createNode nodeGraphEditorInfo -n "MayaNodeEditorSavedTabsInfo";
	rename -uid "84D2DB56-4BB7-AE99-DD75-7A9A081C7DC0";
	setAttr ".tgi[0].tn" -type "string" "Untitled_1";
	setAttr ".tgi[0].vl" -type "double2" -448.27779787627998 -1072.1559710274973 ;
	setAttr ".tgi[0].vh" -type "double2" 1651.6817061406866 -35.411257909876944 ;
	setAttr -s 201 ".tgi[0].ni";
	setAttr ".tgi[0].ni[0].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[0].y" -7.1428570747375488;
	setAttr ".tgi[0].ni[0].nvs" 18304;
	setAttr ".tgi[0].ni[1].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[1].y" -207.14285278320313;
	setAttr ".tgi[0].ni[1].nvs" 18304;
	setAttr ".tgi[0].ni[2].x" 1957.142822265625;
	setAttr ".tgi[0].ni[2].y" -178.57142639160156;
	setAttr ".tgi[0].ni[2].nvs" 18304;
	setAttr ".tgi[0].ni[3].x" 1957.142822265625;
	setAttr ".tgi[0].ni[3].y" 21.428571701049805;
	setAttr ".tgi[0].ni[3].nvs" 18304;
	setAttr ".tgi[0].ni[4].x" -941.4285888671875;
	setAttr ".tgi[0].ni[4].y" -221.42857360839844;
	setAttr ".tgi[0].ni[4].nvs" 18304;
	setAttr ".tgi[0].ni[5].x" 510;
	setAttr ".tgi[0].ni[5].y" -608.5714111328125;
	setAttr ".tgi[0].ni[5].nvs" 18306;
	setAttr ".tgi[0].ni[6].x" 202.85714721679688;
	setAttr ".tgi[0].ni[6].y" -184.28572082519531;
	setAttr ".tgi[0].ni[6].nvs" 18306;
	setAttr ".tgi[0].ni[7].x" 817.14288330078125;
	setAttr ".tgi[0].ni[7].y" -174.28572082519531;
	setAttr ".tgi[0].ni[7].nvs" 18306;
	setAttr ".tgi[0].ni[8].x" 252.85714721679688;
	setAttr ".tgi[0].ni[8].y" -955.71429443359375;
	setAttr ".tgi[0].ni[8].nvs" 18304;
	setAttr ".tgi[0].ni[9].x" 560;
	setAttr ".tgi[0].ni[9].y" -962.85711669921875;
	setAttr ".tgi[0].ni[9].nvs" 18304;
	setAttr ".tgi[0].ni[10].x" 660;
	setAttr ".tgi[0].ni[10].y" -584.28570556640625;
	setAttr ".tgi[0].ni[10].nvs" 18304;
	setAttr ".tgi[0].ni[11].x" 660;
	setAttr ".tgi[0].ni[11].y" -454.28570556640625;
	setAttr ".tgi[0].ni[11].nvs" 18304;
	setAttr ".tgi[0].ni[12].x" 238.57142639160156;
	setAttr ".tgi[0].ni[12].y" -955.71429443359375;
	setAttr ".tgi[0].ni[12].nvs" 18304;
	setAttr ".tgi[0].ni[13].x" -277.14285278320313;
	setAttr ".tgi[0].ni[13].y" -300;
	setAttr ".tgi[0].ni[13].nvs" 18304;
	setAttr ".tgi[0].ni[14].x" 981.4285888671875;
	setAttr ".tgi[0].ni[14].y" -562.85711669921875;
	setAttr ".tgi[0].ni[14].nvs" 18304;
	setAttr ".tgi[0].ni[15].x" 1288.5714111328125;
	setAttr ".tgi[0].ni[15].y" -521.4285888671875;
	setAttr ".tgi[0].ni[15].nvs" 18304;
	setAttr ".tgi[0].ni[16].x" 674.28570556640625;
	setAttr ".tgi[0].ni[16].y" -357.14285278320313;
	setAttr ".tgi[0].ni[16].nvs" 18304;
	setAttr ".tgi[0].ni[17].x" 1178.5714111328125;
	setAttr ".tgi[0].ni[17].y" -148.57142639160156;
	setAttr ".tgi[0].ni[17].nvs" 18304;
	setAttr ".tgi[0].ni[18].x" 367.14285278320313;
	setAttr ".tgi[0].ni[18].y" -397.14285278320313;
	setAttr ".tgi[0].ni[18].nvs" 18304;
	setAttr ".tgi[0].ni[19].x" 367.14285278320313;
	setAttr ".tgi[0].ni[19].y" -165.71427917480469;
	setAttr ".tgi[0].ni[19].nvs" 18304;
	setAttr ".tgi[0].ni[20].x" 674.28570556640625;
	setAttr ".tgi[0].ni[20].y" -458.57144165039063;
	setAttr ".tgi[0].ni[20].nvs" 18304;
	setAttr ".tgi[0].ni[21].x" 981.4285888671875;
	setAttr ".tgi[0].ni[21].y" -461.42855834960938;
	setAttr ".tgi[0].ni[21].nvs" 18304;
	setAttr ".tgi[0].ni[22].x" 674.28570556640625;
	setAttr ".tgi[0].ni[22].y" -661.4285888671875;
	setAttr ".tgi[0].ni[22].nvs" 18304;
	setAttr ".tgi[0].ni[23].x" 981.4285888671875;
	setAttr ".tgi[0].ni[23].y" -664.28570556640625;
	setAttr ".tgi[0].ni[23].nvs" 18304;
	setAttr ".tgi[0].ni[24].x" 1288.5714111328125;
	setAttr ".tgi[0].ni[24].y" -940;
	setAttr ".tgi[0].ni[24].nvs" 18304;
	setAttr ".tgi[0].ni[25].x" 188.57142639160156;
	setAttr ".tgi[0].ni[25].y" -690;
	setAttr ".tgi[0].ni[25].nvs" 18304;
	setAttr ".tgi[0].ni[26].x" 1290;
	setAttr ".tgi[0].ni[26].y" -402.85714721679688;
	setAttr ".tgi[0].ni[26].nvs" 18304;
	setAttr ".tgi[0].ni[27].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[27].y" -1281.4285888671875;
	setAttr ".tgi[0].ni[27].nvs" 18304;
	setAttr ".tgi[0].ni[28].x" 1178.5714111328125;
	setAttr ".tgi[0].ni[28].y" -688.5714111328125;
	setAttr ".tgi[0].ni[28].nvs" 18304;
	setAttr ".tgi[0].ni[29].x" -378.57144165039063;
	setAttr ".tgi[0].ni[29].y" -831.4285888671875;
	setAttr ".tgi[0].ni[29].nvs" 18304;
	setAttr ".tgi[0].ni[30].x" -71.428573608398438;
	setAttr ".tgi[0].ni[30].y" -831.4285888671875;
	setAttr ".tgi[0].ni[30].nvs" 18304;
	setAttr ".tgi[0].ni[31].x" 1290;
	setAttr ".tgi[0].ni[31].y" -200;
	setAttr ".tgi[0].ni[31].nvs" 18304;
	setAttr ".tgi[0].ni[32].x" 1290;
	setAttr ".tgi[0].ni[32].y" -838.5714111328125;
	setAttr ".tgi[0].ni[32].nvs" 18304;
	setAttr ".tgi[0].ni[33].x" 944.28570556640625;
	setAttr ".tgi[0].ni[33].y" -295.71429443359375;
	setAttr ".tgi[0].ni[33].nvs" 18304;
	setAttr ".tgi[0].ni[34].x" 1178.5714111328125;
	setAttr ".tgi[0].ni[34].y" -262.85714721679688;
	setAttr ".tgi[0].ni[34].nvs" 18304;
	setAttr ".tgi[0].ni[35].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[35].y" 138.57142639160156;
	setAttr ".tgi[0].ni[35].nvs" 18304;
	setAttr ".tgi[0].ni[36].x" 1440;
	setAttr ".tgi[0].ni[36].y" -1352.857177734375;
	setAttr ".tgi[0].ni[36].nvs" 18304;
	setAttr ".tgi[0].ni[37].x" 1440;
	setAttr ".tgi[0].ni[37].y" -1222.857177734375;
	setAttr ".tgi[0].ni[37].nvs" 18304;
	setAttr ".tgi[0].ni[38].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[38].y" -64.285713195800781;
	setAttr ".tgi[0].ni[38].nvs" 18304;
	setAttr ".tgi[0].ni[39].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[39].y" -165.71427917480469;
	setAttr ".tgi[0].ni[39].nvs" 18304;
	setAttr ".tgi[0].ni[40].x" 1440;
	setAttr ".tgi[0].ni[40].y" -1092.857177734375;
	setAttr ".tgi[0].ni[40].nvs" 18304;
	setAttr ".tgi[0].ni[41].x" 1440;
	setAttr ".tgi[0].ni[41].y" -962.85711669921875;
	setAttr ".tgi[0].ni[41].nvs" 18304;
	setAttr ".tgi[0].ni[42].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[42].y" -267.14285278320313;
	setAttr ".tgi[0].ni[42].nvs" 18304;
	setAttr ".tgi[0].ni[43].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[43].y" 240;
	setAttr ".tgi[0].ni[43].nvs" 18304;
	setAttr ".tgi[0].ni[44].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[44].y" 37.142856597900391;
	setAttr ".tgi[0].ni[44].nvs" 18304;
	setAttr ".tgi[0].ni[45].x" 1440;
	setAttr ".tgi[0].ni[45].y" -64.285713195800781;
	setAttr ".tgi[0].ni[45].nvs" 18304;
	setAttr ".tgi[0].ni[46].x" 1440;
	setAttr ".tgi[0].ni[46].y" -832.85711669921875;
	setAttr ".tgi[0].ni[46].nvs" 18304;
	setAttr ".tgi[0].ni[47].x" -4.2857141494750977;
	setAttr ".tgi[0].ni[47].y" -185.71427917480469;
	setAttr ".tgi[0].ni[47].nvs" 18304;
	setAttr ".tgi[0].ni[48].x" 200;
	setAttr ".tgi[0].ni[48].y" -844.28570556640625;
	setAttr ".tgi[0].ni[48].nvs" 18304;
	setAttr ".tgi[0].ni[49].x" 637.14288330078125;
	setAttr ".tgi[0].ni[49].y" -622.85711669921875;
	setAttr ".tgi[0].ni[49].nvs" 18304;
	setAttr ".tgi[0].ni[50].x" 507.14285278320313;
	setAttr ".tgi[0].ni[50].y" -714.28570556640625;
	setAttr ".tgi[0].ni[50].nvs" 18304;
	setAttr ".tgi[0].ni[51].x" 814.28570556640625;
	setAttr ".tgi[0].ni[51].y" -714.28570556640625;
	setAttr ".tgi[0].ni[51].nvs" 18304;
	setAttr ".tgi[0].ni[52].x" 660;
	setAttr ".tgi[0].ni[52].y" -844.28570556640625;
	setAttr ".tgi[0].ni[52].nvs" 18304;
	setAttr ".tgi[0].ni[53].x" 200;
	setAttr ".tgi[0].ni[53].y" -584.28570556640625;
	setAttr ".tgi[0].ni[53].nvs" 18304;
	setAttr ".tgi[0].ni[54].x" 660;
	setAttr ".tgi[0].ni[54].y" -584.28570556640625;
	setAttr ".tgi[0].ni[54].nvs" 18304;
	setAttr ".tgi[0].ni[55].x" 814.28570556640625;
	setAttr ".tgi[0].ni[55].y" -454.28570556640625;
	setAttr ".tgi[0].ni[55].nvs" 18304;
	setAttr ".tgi[0].ni[56].x" 660;
	setAttr ".tgi[0].ni[56].y" -714.28570556640625;
	setAttr ".tgi[0].ni[56].nvs" 18304;
	setAttr ".tgi[0].ni[57].x" 814.28570556640625;
	setAttr ".tgi[0].ni[57].y" -324.28570556640625;
	setAttr ".tgi[0].ni[57].nvs" 18304;
	setAttr ".tgi[0].ni[58].x" 814.28570556640625;
	setAttr ".tgi[0].ni[58].y" -194.28572082519531;
	setAttr ".tgi[0].ni[58].nvs" 18304;
	setAttr ".tgi[0].ni[59].x" 200;
	setAttr ".tgi[0].ni[59].y" -324.28570556640625;
	setAttr ".tgi[0].ni[59].nvs" 18304;
	setAttr ".tgi[0].ni[60].x" 814.28570556640625;
	setAttr ".tgi[0].ni[60].y" -844.28570556640625;
	setAttr ".tgi[0].ni[60].nvs" 18304;
	setAttr ".tgi[0].ni[61].x" 507.14285278320313;
	setAttr ".tgi[0].ni[61].y" -454.28570556640625;
	setAttr ".tgi[0].ni[61].nvs" 18304;
	setAttr ".tgi[0].ni[62].x" 660;
	setAttr ".tgi[0].ni[62].y" -714.28570556640625;
	setAttr ".tgi[0].ni[62].nvs" 18304;
	setAttr ".tgi[0].ni[63].x" 544.28570556640625;
	setAttr ".tgi[0].ni[63].y" -501.42855834960938;
	setAttr ".tgi[0].ni[63].nvs" 18304;
	setAttr ".tgi[0].ni[64].x" 814.28570556640625;
	setAttr ".tgi[0].ni[64].y" -584.28570556640625;
	setAttr ".tgi[0].ni[64].nvs" 18304;
	setAttr ".tgi[0].ni[65].x" 200;
	setAttr ".tgi[0].ni[65].y" -714.28570556640625;
	setAttr ".tgi[0].ni[65].nvs" 18304;
	setAttr ".tgi[0].ni[66].x" 660;
	setAttr ".tgi[0].ni[66].y" -584.28570556640625;
	setAttr ".tgi[0].ni[66].nvs" 18304;
	setAttr ".tgi[0].ni[67].x" 200;
	setAttr ".tgi[0].ni[67].y" -454.28570556640625;
	setAttr ".tgi[0].ni[67].nvs" 18304;
	setAttr ".tgi[0].ni[68].x" 507.14285278320313;
	setAttr ".tgi[0].ni[68].y" -844.28570556640625;
	setAttr ".tgi[0].ni[68].nvs" 18304;
	setAttr ".tgi[0].ni[69].x" 507.14285278320313;
	setAttr ".tgi[0].ni[69].y" -324.28570556640625;
	setAttr ".tgi[0].ni[69].nvs" 18304;
	setAttr ".tgi[0].ni[70].x" 200;
	setAttr ".tgi[0].ni[70].y" -194.28572082519531;
	setAttr ".tgi[0].ni[70].nvs" 18304;
	setAttr ".tgi[0].ni[71].x" 660;
	setAttr ".tgi[0].ni[71].y" -584.28570556640625;
	setAttr ".tgi[0].ni[71].nvs" 18304;
	setAttr ".tgi[0].ni[72].x" 507.14285278320313;
	setAttr ".tgi[0].ni[72].y" -194.28572082519531;
	setAttr ".tgi[0].ni[72].nvs" 18304;
	setAttr ".tgi[0].ni[73].x" 507.14285278320313;
	setAttr ".tgi[0].ni[73].y" -584.28570556640625;
	setAttr ".tgi[0].ni[73].nvs" 18304;
	setAttr ".tgi[0].ni[74].x" -277.14285278320313;
	setAttr ".tgi[0].ni[74].y" -198.57142639160156;
	setAttr ".tgi[0].ni[74].nvs" 18304;
	setAttr ".tgi[0].ni[75].x" 674.28570556640625;
	setAttr ".tgi[0].ni[75].y" -560;
	setAttr ".tgi[0].ni[75].nvs" 18304;
	setAttr ".tgi[0].ni[76].x" 981.4285888671875;
	setAttr ".tgi[0].ni[76].y" -360;
	setAttr ".tgi[0].ni[76].nvs" 18304;
	setAttr ".tgi[0].ni[77].x" 1178.5714111328125;
	setAttr ".tgi[0].ni[77].y" -790;
	setAttr ".tgi[0].ni[77].nvs" 18304;
	setAttr ".tgi[0].ni[78].x" -117.14286041259766;
	setAttr ".tgi[0].ni[78].y" -394.28570556640625;
	setAttr ".tgi[0].ni[78].nvs" 18304;
	setAttr ".tgi[0].ni[79].x" -424.28570556640625;
	setAttr ".tgi[0].ni[79].y" -408.57144165039063;
	setAttr ".tgi[0].ni[79].nvs" 18304;
	setAttr ".tgi[0].ni[80].x" 1290;
	setAttr ".tgi[0].ni[80].y" -301.42855834960938;
	setAttr ".tgi[0].ni[80].nvs" 18304;
	setAttr ".tgi[0].ni[81].x" 1132.857177734375;
	setAttr ".tgi[0].ni[81].y" -831.4285888671875;
	setAttr ".tgi[0].ni[81].nvs" 18304;
	setAttr ".tgi[0].ni[82].x" 804.28570556640625;
	setAttr ".tgi[0].ni[82].y" -817.14288330078125;
	setAttr ".tgi[0].ni[82].nvs" 18304;
	setAttr ".tgi[0].ni[83].x" 497.14285278320313;
	setAttr ".tgi[0].ni[83].y" -580;
	setAttr ".tgi[0].ni[83].nvs" 18304;
	setAttr ".tgi[0].ni[84].x" 190;
	setAttr ".tgi[0].ni[84].y" -485.71429443359375;
	setAttr ".tgi[0].ni[84].nvs" 18304;
	setAttr ".tgi[0].ni[85].x" 635.71429443359375;
	setAttr ".tgi[0].ni[85].y" -481.42855834960938;
	setAttr ".tgi[0].ni[85].nvs" 18304;
	setAttr ".tgi[0].ni[86].x" 328.57144165039063;
	setAttr ".tgi[0].ni[86].y" -458.57144165039063;
	setAttr ".tgi[0].ni[86].nvs" 18304;
	setAttr ".tgi[0].ni[87].x" 21.428571701049805;
	setAttr ".tgi[0].ni[87].y" -381.42855834960938;
	setAttr ".tgi[0].ni[87].nvs" 18304;
	setAttr ".tgi[0].ni[88].x" 54.285713195800781;
	setAttr ".tgi[0].ni[88].y" -324.28570556640625;
	setAttr ".tgi[0].ni[88].nvs" 18304;
	setAttr ".tgi[0].ni[89].x" 637.14288330078125;
	setAttr ".tgi[0].ni[89].y" -435.71429443359375;
	setAttr ".tgi[0].ni[89].nvs" 18304;
	setAttr ".tgi[0].ni[90].x" 22.857143402099609;
	setAttr ".tgi[0].ni[90].y" -447.14285278320313;
	setAttr ".tgi[0].ni[90].nvs" 18304;
	setAttr ".tgi[0].ni[91].x" 291.42855834960938;
	setAttr ".tgi[0].ni[91].y" -408.57144165039063;
	setAttr ".tgi[0].ni[91].nvs" 18304;
	setAttr ".tgi[0].ni[92].x" 1395.7142333984375;
	setAttr ".tgi[0].ni[92].y" -705.71429443359375;
	setAttr ".tgi[0].ni[92].nvs" 18304;
	setAttr ".tgi[0].ni[93].x" 1288.5714111328125;
	setAttr ".tgi[0].ni[93].y" -838.5714111328125;
	setAttr ".tgi[0].ni[93].nvs" 18304;
	setAttr ".tgi[0].ni[94].x" 330;
	setAttr ".tgi[0].ni[94].y" -495.71429443359375;
	setAttr ".tgi[0].ni[94].nvs" 18304;
	setAttr ".tgi[0].ni[95].x" 1288.5714111328125;
	setAttr ".tgi[0].ni[95].y" -622.85711669921875;
	setAttr ".tgi[0].ni[95].nvs" 18304;
	setAttr ".tgi[0].ni[96].x" -634.28570556640625;
	setAttr ".tgi[0].ni[96].y" -197.14285278320313;
	setAttr ".tgi[0].ni[96].nvs" 18304;
	setAttr ".tgi[0].ni[97].x" 944.28570556640625;
	setAttr ".tgi[0].ni[97].y" -164.28572082519531;
	setAttr ".tgi[0].ni[97].nvs" 18304;
	setAttr ".tgi[0].ni[98].x" 944.28570556640625;
	setAttr ".tgi[0].ni[98].y" -265.71429443359375;
	setAttr ".tgi[0].ni[98].nvs" 18304;
	setAttr ".tgi[0].ni[99].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[99].y" -1078.5714111328125;
	setAttr ".tgi[0].ni[99].nvs" 18304;
	setAttr ".tgi[0].ni[100].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[100].y" -368.57144165039063;
	setAttr ".tgi[0].ni[100].nvs" 18304;
	setAttr ".tgi[0].ni[101].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[101].y" -774.28570556640625;
	setAttr ".tgi[0].ni[101].nvs" 18304;
	setAttr ".tgi[0].ni[102].x" 942.85711669921875;
	setAttr ".tgi[0].ni[102].y" -164.28572082519531;
	setAttr ".tgi[0].ni[102].nvs" 18304;
	setAttr ".tgi[0].ni[103].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[103].y" -571.4285888671875;
	setAttr ".tgi[0].ni[103].nvs" 18304;
	setAttr ".tgi[0].ni[104].x" 944.28570556640625;
	setAttr ".tgi[0].ni[104].y" -671.4285888671875;
	setAttr ".tgi[0].ni[104].nvs" 18304;
	setAttr ".tgi[0].ni[105].x" 660;
	setAttr ".tgi[0].ni[105].y" -714.28570556640625;
	setAttr ".tgi[0].ni[105].nvs" 18304;
	setAttr ".tgi[0].ni[106].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[106].y" -470;
	setAttr ".tgi[0].ni[106].nvs" 18304;
	setAttr ".tgi[0].ni[107].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[107].y" -672.85711669921875;
	setAttr ".tgi[0].ni[107].nvs" 18304;
	setAttr ".tgi[0].ni[108].x" 944.28570556640625;
	setAttr ".tgi[0].ni[108].y" -367.14285278320313;
	setAttr ".tgi[0].ni[108].nvs" 18304;
	setAttr ".tgi[0].ni[109].x" 942.85711669921875;
	setAttr ".tgi[0].ni[109].y" -265.71429443359375;
	setAttr ".tgi[0].ni[109].nvs" 18304;
	setAttr ".tgi[0].ni[110].x" 942.85711669921875;
	setAttr ".tgi[0].ni[110].y" -367.14285278320313;
	setAttr ".tgi[0].ni[110].nvs" 18304;
	setAttr ".tgi[0].ni[111].x" 942.85711669921875;
	setAttr ".tgi[0].ni[111].y" -570;
	setAttr ".tgi[0].ni[111].nvs" 18304;
	setAttr ".tgi[0].ni[112].x" 30;
	setAttr ".tgi[0].ni[112].y" -108.57142639160156;
	setAttr ".tgi[0].ni[112].nvs" 18304;
	setAttr ".tgi[0].ni[113].x" 660;
	setAttr ".tgi[0].ni[113].y" -714.28570556640625;
	setAttr ".tgi[0].ni[113].nvs" 18304;
	setAttr ".tgi[0].ni[114].x" 944.28570556640625;
	setAttr ".tgi[0].ni[114].y" -570;
	setAttr ".tgi[0].ni[114].nvs" 18304;
	setAttr ".tgi[0].ni[115].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[115].y" -758.5714111328125;
	setAttr ".tgi[0].ni[115].nvs" 18304;
	setAttr ".tgi[0].ni[116].x" 660;
	setAttr ".tgi[0].ni[116].y" -714.28570556640625;
	setAttr ".tgi[0].ni[116].nvs" 18304;
	setAttr ".tgi[0].ni[117].x" 660;
	setAttr ".tgi[0].ni[117].y" -714.28570556640625;
	setAttr ".tgi[0].ni[117].nvs" 18304;
	setAttr ".tgi[0].ni[118].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[118].y" -875.71429443359375;
	setAttr ".tgi[0].ni[118].nvs" 18304;
	setAttr ".tgi[0].ni[119].x" 660;
	setAttr ".tgi[0].ni[119].y" -584.28570556640625;
	setAttr ".tgi[0].ni[119].nvs" 18304;
	setAttr ".tgi[0].ni[120].x" 660;
	setAttr ".tgi[0].ni[120].y" -454.28570556640625;
	setAttr ".tgi[0].ni[120].nvs" 18304;
	setAttr ".tgi[0].ni[121].x" 660;
	setAttr ".tgi[0].ni[121].y" -584.28570556640625;
	setAttr ".tgi[0].ni[121].nvs" 18304;
	setAttr ".tgi[0].ni[122].x" 660;
	setAttr ".tgi[0].ni[122].y" -454.28570556640625;
	setAttr ".tgi[0].ni[122].nvs" 18304;
	setAttr ".tgi[0].ni[123].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[123].y" -454.28570556640625;
	setAttr ".tgi[0].ni[123].nvs" 18304;
	setAttr ".tgi[0].ni[124].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[124].y" -977.14288330078125;
	setAttr ".tgi[0].ni[124].nvs" 18304;
	setAttr ".tgi[0].ni[125].x" 660;
	setAttr ".tgi[0].ni[125].y" -584.28570556640625;
	setAttr ".tgi[0].ni[125].nvs" 18304;
	setAttr ".tgi[0].ni[126].x" 660;
	setAttr ".tgi[0].ni[126].y" -454.28570556640625;
	setAttr ".tgi[0].ni[126].nvs" 18304;
	setAttr ".tgi[0].ni[127].x" 660;
	setAttr ".tgi[0].ni[127].y" -454.28570556640625;
	setAttr ".tgi[0].ni[127].nvs" 18304;
	setAttr ".tgi[0].ni[128].x" 660;
	setAttr ".tgi[0].ni[128].y" -454.28570556640625;
	setAttr ".tgi[0].ni[128].nvs" 18304;
	setAttr ".tgi[0].ni[129].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[129].y" -352.85714721679688;
	setAttr ".tgi[0].ni[129].nvs" 18304;
	setAttr ".tgi[0].ni[130].x" 660;
	setAttr ".tgi[0].ni[130].y" -584.28570556640625;
	setAttr ".tgi[0].ni[130].nvs" 18304;
	setAttr ".tgi[0].ni[131].x" 660;
	setAttr ".tgi[0].ni[131].y" -454.28570556640625;
	setAttr ".tgi[0].ni[131].nvs" 18304;
	setAttr ".tgi[0].ni[132].x" 942.85711669921875;
	setAttr ".tgi[0].ni[132].y" -468.57144165039063;
	setAttr ".tgi[0].ni[132].nvs" 18304;
	setAttr ".tgi[0].ni[133].x" 942.85711669921875;
	setAttr ".tgi[0].ni[133].y" -772.85711669921875;
	setAttr ".tgi[0].ni[133].nvs" 18304;
	setAttr ".tgi[0].ni[134].x" 660;
	setAttr ".tgi[0].ni[134].y" -714.28570556640625;
	setAttr ".tgi[0].ni[134].nvs" 18304;
	setAttr ".tgi[0].ni[135].x" 660;
	setAttr ".tgi[0].ni[135].y" -584.28570556640625;
	setAttr ".tgi[0].ni[135].nvs" 18304;
	setAttr ".tgi[0].ni[136].x" 942.85711669921875;
	setAttr ".tgi[0].ni[136].y" -874.28570556640625;
	setAttr ".tgi[0].ni[136].nvs" 18304;
	setAttr ".tgi[0].ni[137].x" 944.28570556640625;
	setAttr ".tgi[0].ni[137].y" -468.57144165039063;
	setAttr ".tgi[0].ni[137].nvs" 18304;
	setAttr ".tgi[0].ni[138].x" 942.85711669921875;
	setAttr ".tgi[0].ni[138].y" -671.4285888671875;
	setAttr ".tgi[0].ni[138].nvs" 18304;
	setAttr ".tgi[0].ni[139].x" 944.28570556640625;
	setAttr ".tgi[0].ni[139].y" -772.85711669921875;
	setAttr ".tgi[0].ni[139].nvs" 18304;
	setAttr ".tgi[0].ni[140].x" 944.28570556640625;
	setAttr ".tgi[0].ni[140].y" -874.28570556640625;
	setAttr ".tgi[0].ni[140].nvs" 18304;
	setAttr ".tgi[0].ni[141].x" 1111.4285888671875;
	setAttr ".tgi[0].ni[141].y" -1180;
	setAttr ".tgi[0].ni[141].nvs" 18304;
	setAttr ".tgi[0].ni[142].x" 30;
	setAttr ".tgi[0].ni[142].y" -324.28570556640625;
	setAttr ".tgi[0].ni[142].nvs" 18304;
	setAttr ".tgi[0].ni[143].x" -218.57142639160156;
	setAttr ".tgi[0].ni[143].y" -174.28572082519531;
	setAttr ".tgi[0].ni[143].nvs" 18304;
	setAttr ".tgi[0].ni[144].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[144].y" -657.14288330078125;
	setAttr ".tgi[0].ni[144].nvs" 18304;
	setAttr ".tgi[0].ni[145].x" 330;
	setAttr ".tgi[0].ni[145].y" -578.5714111328125;
	setAttr ".tgi[0].ni[145].nvs" 18304;
	setAttr ".tgi[0].ni[146].x" 188.57142639160156;
	setAttr ".tgi[0].ni[146].y" -687.14288330078125;
	setAttr ".tgi[0].ni[146].nvs" 18304;
	setAttr ".tgi[0].ni[147].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[147].y" -860;
	setAttr ".tgi[0].ni[147].nvs" 18304;
	setAttr ".tgi[0].ni[148].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[148].y" -555.71429443359375;
	setAttr ".tgi[0].ni[148].nvs" 18304;
	setAttr ".tgi[0].ni[149].x" 352.85714721679688;
	setAttr ".tgi[0].ni[149].y" -297.14285278320313;
	setAttr ".tgi[0].ni[149].nvs" 18304;
	setAttr ".tgi[0].ni[150].x" 45.714286804199219;
	setAttr ".tgi[0].ni[150].y" -297.14285278320313;
	setAttr ".tgi[0].ni[150].nvs" 18304;
	setAttr ".tgi[0].ni[151].x" 237.14285278320313;
	setAttr ".tgi[0].ni[151].y" -435.71429443359375;
	setAttr ".tgi[0].ni[151].nvs" 18304;
	setAttr ".tgi[0].ni[152].x" 1595.7142333984375;
	setAttr ".tgi[0].ni[152].y" -961.4285888671875;
	setAttr ".tgi[0].ni[152].nvs" 18304;
	setAttr ".tgi[0].ni[153].x" 45.714286804199219;
	setAttr ".tgi[0].ni[153].y" 35.714286804199219;
	setAttr ".tgi[0].ni[153].nvs" 18304;
	setAttr ".tgi[0].ni[154].x" 352.85714721679688;
	setAttr ".tgi[0].ni[154].y" 35.714286804199219;
	setAttr ".tgi[0].ni[154].nvs" 18304;
	setAttr ".tgi[0].ni[155].x" 350;
	setAttr ".tgi[0].ni[155].y" -621.4285888671875;
	setAttr ".tgi[0].ni[155].nvs" 18304;
	setAttr ".tgi[0].ni[156].x" 350;
	setAttr ".tgi[0].ni[156].y" -418.57144165039063;
	setAttr ".tgi[0].ni[156].nvs" 18304;
	setAttr ".tgi[0].ni[157].x" 657.14288330078125;
	setAttr ".tgi[0].ni[157].y" -520;
	setAttr ".tgi[0].ni[157].nvs" 18304;
	setAttr ".tgi[0].ni[158].x" 1434.2857666015625;
	setAttr ".tgi[0].ni[158].y" -577.14288330078125;
	setAttr ".tgi[0].ni[158].nvs" 18304;
	setAttr ".tgi[0].ni[159].x" 350;
	setAttr ".tgi[0].ni[159].y" -520;
	setAttr ".tgi[0].ni[159].nvs" 18304;
	setAttr ".tgi[0].ni[160].x" 660;
	setAttr ".tgi[0].ni[160].y" -650;
	setAttr ".tgi[0].ni[160].nvs" 18304;
	setAttr ".tgi[0].ni[161].x" 660;
	setAttr ".tgi[0].ni[161].y" -584.28570556640625;
	setAttr ".tgi[0].ni[161].nvs" 18304;
	setAttr ".tgi[0].ni[162].x" 1395.7142333984375;
	setAttr ".tgi[0].ni[162].y" -191.42857360839844;
	setAttr ".tgi[0].ni[162].nvs" 18304;
	setAttr ".tgi[0].ni[163].x" 1395.7142333984375;
	setAttr ".tgi[0].ni[163].y" -321.42855834960938;
	setAttr ".tgi[0].ni[163].nvs" 18304;
	setAttr ".tgi[0].ni[164].x" 352.85714721679688;
	setAttr ".tgi[0].ni[164].y" -520;
	setAttr ".tgi[0].ni[164].nvs" 18304;
	setAttr ".tgi[0].ni[165].x" 660;
	setAttr ".tgi[0].ni[165].y" -520;
	setAttr ".tgi[0].ni[165].nvs" 18304;
	setAttr ".tgi[0].ni[166].x" -218.57142639160156;
	setAttr ".tgi[0].ni[166].y" -280;
	setAttr ".tgi[0].ni[166].nvs" 18304;
	setAttr ".tgi[0].ni[167].x" 352.85714721679688;
	setAttr ".tgi[0].ni[167].y" -454.28570556640625;
	setAttr ".tgi[0].ni[167].nvs" 18304;
	setAttr ".tgi[0].ni[168].x" 660;
	setAttr ".tgi[0].ni[168].y" -454.28570556640625;
	setAttr ".tgi[0].ni[168].nvs" 18304;
	setAttr ".tgi[0].ni[169].x" 352.85714721679688;
	setAttr ".tgi[0].ni[169].y" -584.28570556640625;
	setAttr ".tgi[0].ni[169].nvs" 18304;
	setAttr ".tgi[0].ni[170].x" 674.28570556640625;
	setAttr ".tgi[0].ni[170].y" -68.571426391601563;
	setAttr ".tgi[0].ni[170].nvs" 18304;
	setAttr ".tgi[0].ni[171].x" -228.57142639160156;
	setAttr ".tgi[0].ni[171].y" -728.5714111328125;
	setAttr ".tgi[0].ni[171].nvs" 18304;
	setAttr ".tgi[0].ni[172].x" -378.57144165039063;
	setAttr ".tgi[0].ni[172].y" -608.5714111328125;
	setAttr ".tgi[0].ni[172].nvs" 18304;
	setAttr ".tgi[0].ni[173].x" 851.4285888671875;
	setAttr ".tgi[0].ni[173].y" -721.4285888671875;
	setAttr ".tgi[0].ni[173].nvs" 18304;
	setAttr ".tgi[0].ni[174].x" -634.28570556640625;
	setAttr ".tgi[0].ni[174].y" -298.57144165039063;
	setAttr ".tgi[0].ni[174].nvs" 18304;
	setAttr ".tgi[0].ni[175].x" -201.42857360839844;
	setAttr ".tgi[0].ni[175].y" -68.571426391601563;
	setAttr ".tgi[0].ni[175].nvs" 18304;
	setAttr ".tgi[0].ni[176].x" -432.85714721679688;
	setAttr ".tgi[0].ni[176].y" -174.28572082519531;
	setAttr ".tgi[0].ni[176].nvs" 18304;
	setAttr ".tgi[0].ni[177].x" 660;
	setAttr ".tgi[0].ni[177].y" -398.57144165039063;
	setAttr ".tgi[0].ni[177].nvs" 18304;
	setAttr ".tgi[0].ni[178].x" 660;
	setAttr ".tgi[0].ni[178].y" -584.28570556640625;
	setAttr ".tgi[0].ni[178].nvs" 18304;
	setAttr ".tgi[0].ni[179].x" 660;
	setAttr ".tgi[0].ni[179].y" -454.28570556640625;
	setAttr ".tgi[0].ni[179].nvs" 18304;
	setAttr ".tgi[0].ni[180].x" 967.14288330078125;
	setAttr ".tgi[0].ni[180].y" -1178.5714111328125;
	setAttr ".tgi[0].ni[180].nvs" 18304;
	setAttr ".tgi[0].ni[181].x" 967.14288330078125;
	setAttr ".tgi[0].ni[181].y" -1048.5714111328125;
	setAttr ".tgi[0].ni[181].nvs" 18304;
	setAttr ".tgi[0].ni[182].x" 660;
	setAttr ".tgi[0].ni[182].y" -195.71427917480469;
	setAttr ".tgi[0].ni[182].nvs" 18304;
	setAttr ".tgi[0].ni[183].x" 967.14288330078125;
	setAttr ".tgi[0].ni[183].y" -788.5714111328125;
	setAttr ".tgi[0].ni[183].nvs" 18304;
	setAttr ".tgi[0].ni[184].x" 660;
	setAttr ".tgi[0].ni[184].y" 137.14285278320313;
	setAttr ".tgi[0].ni[184].nvs" 18304;
	setAttr ".tgi[0].ni[185].x" 967.14288330078125;
	setAttr ".tgi[0].ni[185].y" -658.5714111328125;
	setAttr ".tgi[0].ni[185].nvs" 18304;
	setAttr ".tgi[0].ni[186].x" 660;
	setAttr ".tgi[0].ni[186].y" -65.714286804199219;
	setAttr ".tgi[0].ni[186].nvs" 18304;
	setAttr ".tgi[0].ni[187].x" 507.14285278320313;
	setAttr ".tgi[0].ni[187].y" -960;
	setAttr ".tgi[0].ni[187].nvs" 18304;
	setAttr ".tgi[0].ni[188].x" 82.857139587402344;
	setAttr ".tgi[0].ni[188].y" -35.714286804199219;
	setAttr ".tgi[0].ni[188].nvs" 18304;
	setAttr ".tgi[0].ni[189].x" -94.285713195800781;
	setAttr ".tgi[0].ni[189].y" -588.5714111328125;
	setAttr ".tgi[0].ni[189].nvs" 18304;
	setAttr ".tgi[0].ni[190].x" 660;
	setAttr ".tgi[0].ni[190].y" -714.28570556640625;
	setAttr ".tgi[0].ni[190].nvs" 18304;
	setAttr ".tgi[0].ni[191].x" 660;
	setAttr ".tgi[0].ni[191].y" -714.28570556640625;
	setAttr ".tgi[0].ni[191].nvs" 18304;
	setAttr ".tgi[0].ni[192].x" 352.85714721679688;
	setAttr ".tgi[0].ni[192].y" -520;
	setAttr ".tgi[0].ni[192].nvs" 18304;
	setAttr ".tgi[0].ni[193].x" 660;
	setAttr ".tgi[0].ni[193].y" -520;
	setAttr ".tgi[0].ni[193].nvs" 18304;
	setAttr ".tgi[0].ni[194].x" 82.857139587402344;
	setAttr ".tgi[0].ni[194].y" -35.714286804199219;
	setAttr ".tgi[0].ni[194].nvs" 18304;
	setAttr ".tgi[0].ni[195].x" 390;
	setAttr ".tgi[0].ni[195].y" -35.714286804199219;
	setAttr ".tgi[0].ni[195].nvs" 18304;
	setAttr ".tgi[0].ni[196].x" 390;
	setAttr ".tgi[0].ni[196].y" -35.714286804199219;
	setAttr ".tgi[0].ni[196].nvs" 18304;
	setAttr ".tgi[0].ni[197].x" 660;
	setAttr ".tgi[0].ni[197].y" -454.28570556640625;
	setAttr ".tgi[0].ni[197].nvs" 18304;
	setAttr ".tgi[0].ni[198].x" 660;
	setAttr ".tgi[0].ni[198].y" -454.28570556640625;
	setAttr ".tgi[0].ni[198].nvs" 18304;
	setAttr ".tgi[0].ni[199].x" 660;
	setAttr ".tgi[0].ni[199].y" -584.28570556640625;
	setAttr ".tgi[0].ni[199].nvs" 18304;
	setAttr ".tgi[0].ni[200].x" 660;
	setAttr ".tgi[0].ni[200].y" -454.28570556640625;
	setAttr ".tgi[0].ni[200].nvs" 18304;
createNode nodeGraphEditorInfo -n "hyperShadePrimaryNodeEditorSavedTabsInfo";
	rename -uid "E3589179-4A05-3AD2-9378-F7AA21ABFBE3";
	setAttr ".tgi[0].tn" -type "string" "Untitled_1";
	setAttr ".tgi[0].vl" -type "double2" -328.57141551517361 -323.80951094248991 ;
	setAttr ".tgi[0].vh" -type "double2" 297.61903579272968 338.09522466054096 ;
createNode displayLayer -n "skeleton";
	rename -uid "AC9A3FE1-428A-71F1-F12E-42A762D831B0";
	setAttr ".v" no;
	setAttr ".c" 1;
	setAttr ".do" 1;
select -ne :time1;
	setAttr -av -k on ".cch";
	setAttr -av -cb on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -k on ".o" 0;
	setAttr -av -k on ".unw";
	setAttr -k on ".etw";
	setAttr -k on ".tps";
	setAttr -av -k on ".tms";
select -ne :hardwareRenderingGlobals;
	setAttr -k on ".ihi";
	setAttr ".vac" 2;
	setAttr -av ".ta";
	setAttr ".etmr" no;
	setAttr ".tmr" 4096;
	setAttr -av ".aoam";
	setAttr -av ".aora";
	setAttr -av ".mbe";
	setAttr -k on ".mbsof";
	setAttr ".msaa" yes;
select -ne :renderPartition;
	setAttr -av -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -s 9 ".st";
	setAttr -cb on ".an";
	setAttr -cb on ".pt";
select -ne :renderGlobalsList1;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
select -ne :defaultShaderList1;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -s 8 ".s";
select -ne :postProcessList1;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -s 2 ".p";
select -ne :defaultRenderUtilityList1;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -s 9 ".u";
select -ne :defaultRenderingList1;
	setAttr -k on ".ihi";
select -ne :defaultTextureList1;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -s 2 ".tx";
select -ne :initialShadingGroup;
	setAttr -av -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -k on ".mwc";
	setAttr -cb on ".an";
	setAttr -cb on ".il";
	setAttr -cb on ".vo";
	setAttr -cb on ".eo";
	setAttr -cb on ".fo";
	setAttr -cb on ".epo";
	setAttr -k on ".ro" yes;
select -ne :initialParticleSE;
	setAttr -av -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -k on ".mwc";
	setAttr -cb on ".an";
	setAttr -cb on ".il";
	setAttr -cb on ".vo";
	setAttr -cb on ".eo";
	setAttr -cb on ".fo";
	setAttr -cb on ".epo";
	setAttr -k on ".ro" yes;
select -ne :defaultRenderGlobals;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -k on ".macc";
	setAttr -k on ".macd";
	setAttr -k on ".macq";
	setAttr -k on ".mcfr" 30;
	setAttr -cb on ".ifg";
	setAttr -k on ".clip";
	setAttr -k on ".edm";
	setAttr -k on ".edl";
	setAttr -cb on ".ren";
	setAttr -av -k on ".esr";
	setAttr -k on ".ors";
	setAttr -cb on ".sdf";
	setAttr -av -k on ".outf";
	setAttr -cb on ".imfkey";
	setAttr -k on ".gama";
	setAttr -k on ".an";
	setAttr -cb on ".ar";
	setAttr -k on ".fs";
	setAttr -k on ".ef";
	setAttr -av -k on ".bfs";
	setAttr -cb on ".me";
	setAttr -cb on ".se";
	setAttr -k on ".be";
	setAttr -cb on ".ep" 1;
	setAttr -k on ".fec";
	setAttr -av -k on ".ofc";
	setAttr -cb on ".ofe";
	setAttr -cb on ".efe";
	setAttr -cb on ".oft";
	setAttr -cb on ".umfn";
	setAttr -cb on ".ufe";
	setAttr -cb on ".pff";
	setAttr -cb on ".peie";
	setAttr -cb on ".ifp";
	setAttr -k on ".comp";
	setAttr -k on ".cth";
	setAttr -k on ".soll";
	setAttr -k on ".sosl";
	setAttr -k on ".rd";
	setAttr -k on ".lp";
	setAttr -av -k on ".sp";
	setAttr -k on ".shs";
	setAttr -av -k on ".lpr";
	setAttr -cb on ".gv";
	setAttr -cb on ".sv";
	setAttr -k on ".mm";
	setAttr -k on ".npu";
	setAttr -k on ".itf";
	setAttr -k on ".shp";
	setAttr -cb on ".isp";
	setAttr -k on ".uf";
	setAttr -k on ".oi";
	setAttr -k on ".rut";
	setAttr -k on ".mb";
	setAttr -av -k on ".mbf";
	setAttr -k on ".afp";
	setAttr -k on ".pfb";
	setAttr -k on ".pram";
	setAttr -k on ".poam";
	setAttr -k on ".prlm";
	setAttr -k on ".polm";
	setAttr -cb on ".prm";
	setAttr -cb on ".pom";
	setAttr -cb on ".pfrm";
	setAttr -cb on ".pfom";
	setAttr -av -k on ".bll";
	setAttr -k on ".bls";
	setAttr -av -k on ".smv";
	setAttr -k on ".ubc";
	setAttr -k on ".mbc";
	setAttr -cb on ".mbt";
	setAttr -k on ".udbx";
	setAttr -k on ".smc";
	setAttr -k on ".kmv";
	setAttr -cb on ".isl";
	setAttr -cb on ".ism";
	setAttr -cb on ".imb";
	setAttr -k on ".rlen";
	setAttr -av -k on ".frts";
	setAttr -k on ".tlwd";
	setAttr -k on ".tlht";
	setAttr -k on ".jfc";
	setAttr -cb on ".rsb";
	setAttr -k on ".ope";
	setAttr -k on ".oppf";
	setAttr -cb on ".hbl";
select -ne :defaultResolution;
	setAttr -av -k on ".cch";
	setAttr -av -k on ".ihi";
	setAttr -av -k on ".nds";
	setAttr -k on ".bnm";
	setAttr -av -k on ".w" 640;
	setAttr -av -k on ".h" 480;
	setAttr -av -k on ".pa" 1;
	setAttr -av -k on ".al";
	setAttr -av -k on ".dar" 1.3333332538604736;
	setAttr -av -k on ".ldar";
	setAttr -av -k on ".dpi";
	setAttr -av -k on ".off";
	setAttr -av -k on ".fld";
	setAttr -av -k on ".zsl";
	setAttr -av -k on ".isu";
	setAttr -av -k on ".pdu";
select -ne :defaultColorMgtGlobals;
	setAttr ".cme" no;
select -ne :hardwareRenderGlobals;
	setAttr -k on ".cch";
	setAttr -cb on ".ihi";
	setAttr -k on ".nds";
	setAttr -cb on ".bnm";
	setAttr -k off ".ctrs" 256;
	setAttr -av -k off ".btrs" 512;
	setAttr -k off -cb on ".fbfm";
	setAttr -k off -cb on ".ehql";
	setAttr -k off -cb on ".eams";
	setAttr -k off -cb on ".eeaa";
	setAttr -k off -cb on ".engm";
	setAttr -k off -cb on ".mes";
	setAttr -k off -cb on ".emb";
	setAttr -av -k off -cb on ".mbbf";
	setAttr -k off -cb on ".mbs";
	setAttr -k off -cb on ".trm";
	setAttr -k off -cb on ".tshc";
	setAttr -k off -cb on ".enpt";
	setAttr -k off -cb on ".clmt";
	setAttr -k off -cb on ".tcov";
	setAttr -k off -cb on ".lith";
	setAttr -k off -cb on ".sobc";
	setAttr -k off -cb on ".cuth";
	setAttr -k off -cb on ".hgcd";
	setAttr -k off -cb on ".hgci";
	setAttr -k off -cb on ".mgcs";
	setAttr -k off -cb on ".twa";
	setAttr -k off -cb on ".twz";
	setAttr -cb on ".hwcc";
	setAttr -cb on ".hwdp";
	setAttr -cb on ".hwql";
	setAttr -k on ".hwfr" 30;
	setAttr -k on ".soll";
	setAttr -k on ".sosl";
	setAttr -k on ".bswa";
	setAttr -k on ".shml";
	setAttr -k on ".hwel";
select -ne :ikSystem;
	setAttr -s 2 ".sol";
connectAttr "skeleton.di" "j_root.do";
connectAttr "j_root.s" "j_pelvis.is";
connectAttr "j_pelvis_parentConstraint1.ctx" "j_pelvis.tx";
connectAttr "j_pelvis_parentConstraint1.cty" "j_pelvis.ty";
connectAttr "j_pelvis_parentConstraint1.ctz" "j_pelvis.tz";
connectAttr "j_pelvis_parentConstraint1.crx" "j_pelvis.rx";
connectAttr "j_pelvis_parentConstraint1.cry" "j_pelvis.ry";
connectAttr "j_pelvis_parentConstraint1.crz" "j_pelvis.rz";
connectAttr "skeleton.di" "j_pelvis.do";
connectAttr "j_pelvis.s" "j_spine_01.is";
connectAttr "j_spine_01_parentConstraint1.ctx" "j_spine_01.tx";
connectAttr "j_spine_01_parentConstraint1.cty" "j_spine_01.ty";
connectAttr "j_spine_01_parentConstraint1.ctz" "j_spine_01.tz";
connectAttr "j_spine_01_parentConstraint1.crx" "j_spine_01.rx";
connectAttr "j_spine_01_parentConstraint1.cry" "j_spine_01.ry";
connectAttr "j_spine_01_parentConstraint1.crz" "j_spine_01.rz";
connectAttr "skeleton.di" "j_spine_01.do";
connectAttr "j_spine_01.s" "j_spine_02.is";
connectAttr "j_spine_02_parentConstraint1.ctx" "j_spine_02.tx";
connectAttr "j_spine_02_parentConstraint1.cty" "j_spine_02.ty";
connectAttr "j_spine_02_parentConstraint1.ctz" "j_spine_02.tz";
connectAttr "j_spine_02_parentConstraint1.crx" "j_spine_02.rx";
connectAttr "j_spine_02_parentConstraint1.cry" "j_spine_02.ry";
connectAttr "j_spine_02_parentConstraint1.crz" "j_spine_02.rz";
connectAttr "skeleton.di" "j_spine_02.do";
connectAttr "j_spine_02.s" "j_spine_03.is";
connectAttr "j_spine_03_parentConstraint1.ctx" "j_spine_03.tx";
connectAttr "j_spine_03_parentConstraint1.cty" "j_spine_03.ty";
connectAttr "j_spine_03_parentConstraint1.ctz" "j_spine_03.tz";
connectAttr "j_spine_03_parentConstraint1.crx" "j_spine_03.rx";
connectAttr "j_spine_03_parentConstraint1.cry" "j_spine_03.ry";
connectAttr "j_spine_03_parentConstraint1.crz" "j_spine_03.rz";
connectAttr "skeleton.di" "j_spine_03.do";
connectAttr "j_neck_parentConstraint1.ctx" "j_neck.tx";
connectAttr "j_neck_parentConstraint1.cty" "j_neck.ty";
connectAttr "j_neck_parentConstraint1.ctz" "j_neck.tz";
connectAttr "j_neck_parentConstraint1.crx" "j_neck.rx";
connectAttr "j_neck_parentConstraint1.cry" "j_neck.ry";
connectAttr "j_neck_parentConstraint1.crz" "j_neck.rz";
connectAttr "j_spine_03.s" "j_neck.is";
connectAttr "j_head_parentConstraint1.ctx" "j_head.tx";
connectAttr "j_head_parentConstraint1.cty" "j_head.ty";
connectAttr "j_head_parentConstraint1.ctz" "j_head.tz";
connectAttr "j_head_parentConstraint1.crx" "j_head.rx";
connectAttr "j_head_parentConstraint1.cry" "j_head.ry";
connectAttr "j_head_parentConstraint1.crz" "j_head.rz";
connectAttr "j_neck.s" "j_head.is";
connectAttr "j_head.s" "j_r_ear_01.is";
connectAttr "j_r_ear_01_parentConstraint1.ctx" "j_r_ear_01.tx";
connectAttr "j_r_ear_01_parentConstraint1.cty" "j_r_ear_01.ty";
connectAttr "j_r_ear_01_parentConstraint1.ctz" "j_r_ear_01.tz";
connectAttr "j_r_ear_01_parentConstraint1.crx" "j_r_ear_01.rx";
connectAttr "j_r_ear_01_parentConstraint1.cry" "j_r_ear_01.ry";
connectAttr "j_r_ear_01_parentConstraint1.crz" "j_r_ear_01.rz";
connectAttr "j_r_ear_01.s" "j_r_ear_02.is";
connectAttr "j_r_ear_02_parentConstraint1.ctx" "j_r_ear_02.tx";
connectAttr "j_r_ear_02_parentConstraint1.cty" "j_r_ear_02.ty";
connectAttr "j_r_ear_02_parentConstraint1.ctz" "j_r_ear_02.tz";
connectAttr "j_r_ear_02_parentConstraint1.crx" "j_r_ear_02.rx";
connectAttr "j_r_ear_02_parentConstraint1.cry" "j_r_ear_02.ry";
connectAttr "j_r_ear_02_parentConstraint1.crz" "j_r_ear_02.rz";
connectAttr "j_r_ear_02.ro" "j_r_ear_02_parentConstraint1.cro";
connectAttr "j_r_ear_02.pim" "j_r_ear_02_parentConstraint1.cpim";
connectAttr "j_r_ear_02.rp" "j_r_ear_02_parentConstraint1.crp";
connectAttr "j_r_ear_02.rpt" "j_r_ear_02_parentConstraint1.crt";
connectAttr "j_r_ear_02.jo" "j_r_ear_02_parentConstraint1.cjo";
connectAttr "ctrl_j_r_ear_02.t" "j_r_ear_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_ear_02.rp" "j_r_ear_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_ear_02.rpt" "j_r_ear_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_ear_02.r" "j_r_ear_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_ear_02.ro" "j_r_ear_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_ear_02.s" "j_r_ear_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_ear_02.pm" "j_r_ear_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_ear_02.jo" "j_r_ear_02_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_ear_02.ssc" "j_r_ear_02_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_ear_02.is" "j_r_ear_02_parentConstraint1.tg[0].tis";
connectAttr "j_r_ear_02_parentConstraint1.w0" "j_r_ear_02_parentConstraint1.tg[0].tw"
		;
connectAttr "j_r_ear_01.ro" "j_r_ear_01_parentConstraint1.cro";
connectAttr "j_r_ear_01.pim" "j_r_ear_01_parentConstraint1.cpim";
connectAttr "j_r_ear_01.rp" "j_r_ear_01_parentConstraint1.crp";
connectAttr "j_r_ear_01.rpt" "j_r_ear_01_parentConstraint1.crt";
connectAttr "j_r_ear_01.jo" "j_r_ear_01_parentConstraint1.cjo";
connectAttr "ctrl_j_r_ear_01.t" "j_r_ear_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_ear_01.rp" "j_r_ear_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_ear_01.rpt" "j_r_ear_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_ear_01.r" "j_r_ear_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_ear_01.ro" "j_r_ear_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_ear_01.s" "j_r_ear_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_ear_01.pm" "j_r_ear_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_ear_01.jo" "j_r_ear_01_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_ear_01.ssc" "j_r_ear_01_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_ear_01.is" "j_r_ear_01_parentConstraint1.tg[0].tis";
connectAttr "j_r_ear_01_parentConstraint1.w0" "j_r_ear_01_parentConstraint1.tg[0].tw"
		;
connectAttr "j_head.s" "j_l_ear_01.is";
connectAttr "j_l_ear_01_parentConstraint1.ctx" "j_l_ear_01.tx";
connectAttr "j_l_ear_01_parentConstraint1.cty" "j_l_ear_01.ty";
connectAttr "j_l_ear_01_parentConstraint1.ctz" "j_l_ear_01.tz";
connectAttr "j_l_ear_01_parentConstraint1.crx" "j_l_ear_01.rx";
connectAttr "j_l_ear_01_parentConstraint1.cry" "j_l_ear_01.ry";
connectAttr "j_l_ear_01_parentConstraint1.crz" "j_l_ear_01.rz";
connectAttr "j_l_ear_01.s" "j_l_ear_02.is";
connectAttr "j_l_ear_02_parentConstraint1.ctx" "j_l_ear_02.tx";
connectAttr "j_l_ear_02_parentConstraint1.cty" "j_l_ear_02.ty";
connectAttr "j_l_ear_02_parentConstraint1.ctz" "j_l_ear_02.tz";
connectAttr "j_l_ear_02_parentConstraint1.crx" "j_l_ear_02.rx";
connectAttr "j_l_ear_02_parentConstraint1.cry" "j_l_ear_02.ry";
connectAttr "j_l_ear_02_parentConstraint1.crz" "j_l_ear_02.rz";
connectAttr "j_l_ear_02.ro" "j_l_ear_02_parentConstraint1.cro";
connectAttr "j_l_ear_02.pim" "j_l_ear_02_parentConstraint1.cpim";
connectAttr "j_l_ear_02.rp" "j_l_ear_02_parentConstraint1.crp";
connectAttr "j_l_ear_02.rpt" "j_l_ear_02_parentConstraint1.crt";
connectAttr "j_l_ear_02.jo" "j_l_ear_02_parentConstraint1.cjo";
connectAttr "ctrl_j_l_ear_02.t" "j_l_ear_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_ear_02.rp" "j_l_ear_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_ear_02.rpt" "j_l_ear_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_ear_02.r" "j_l_ear_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_ear_02.ro" "j_l_ear_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_ear_02.s" "j_l_ear_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_ear_02.pm" "j_l_ear_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_ear_02.jo" "j_l_ear_02_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_ear_02.ssc" "j_l_ear_02_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_ear_02.is" "j_l_ear_02_parentConstraint1.tg[0].tis";
connectAttr "j_l_ear_02_parentConstraint1.w0" "j_l_ear_02_parentConstraint1.tg[0].tw"
		;
connectAttr "j_l_ear_01.ro" "j_l_ear_01_parentConstraint1.cro";
connectAttr "j_l_ear_01.pim" "j_l_ear_01_parentConstraint1.cpim";
connectAttr "j_l_ear_01.rp" "j_l_ear_01_parentConstraint1.crp";
connectAttr "j_l_ear_01.rpt" "j_l_ear_01_parentConstraint1.crt";
connectAttr "j_l_ear_01.jo" "j_l_ear_01_parentConstraint1.cjo";
connectAttr "ctrl_j_l_ear_01.t" "j_l_ear_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_ear_01.rp" "j_l_ear_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_ear_01.rpt" "j_l_ear_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_ear_01.r" "j_l_ear_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_ear_01.ro" "j_l_ear_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_ear_01.s" "j_l_ear_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_ear_01.pm" "j_l_ear_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_ear_01.jo" "j_l_ear_01_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_ear_01.ssc" "j_l_ear_01_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_ear_01.is" "j_l_ear_01_parentConstraint1.tg[0].tis";
connectAttr "j_l_ear_01_parentConstraint1.w0" "j_l_ear_01_parentConstraint1.tg[0].tw"
		;
connectAttr "j_head.ro" "j_head_parentConstraint1.cro";
connectAttr "j_head.pim" "j_head_parentConstraint1.cpim";
connectAttr "j_head.rp" "j_head_parentConstraint1.crp";
connectAttr "j_head.rpt" "j_head_parentConstraint1.crt";
connectAttr "j_head.jo" "j_head_parentConstraint1.cjo";
connectAttr "ctrl_j_head.t" "j_head_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_head.rp" "j_head_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_head.rpt" "j_head_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_head.r" "j_head_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_head.ro" "j_head_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_head.s" "j_head_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_head.pm" "j_head_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_head.jo" "j_head_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_head.ssc" "j_head_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_head.is" "j_head_parentConstraint1.tg[0].tis";
connectAttr "j_head_parentConstraint1.w0" "j_head_parentConstraint1.tg[0].tw";
connectAttr "j_neck.ro" "j_neck_parentConstraint1.cro";
connectAttr "j_neck.pim" "j_neck_parentConstraint1.cpim";
connectAttr "j_neck.rp" "j_neck_parentConstraint1.crp";
connectAttr "j_neck.rpt" "j_neck_parentConstraint1.crt";
connectAttr "j_neck.jo" "j_neck_parentConstraint1.cjo";
connectAttr "ctrl_j_neck.t" "j_neck_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_neck.rp" "j_neck_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_neck.rpt" "j_neck_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_neck.r" "j_neck_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_neck.ro" "j_neck_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_neck.s" "j_neck_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_neck.pm" "j_neck_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_neck.jo" "j_neck_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_neck.ssc" "j_neck_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_neck.is" "j_neck_parentConstraint1.tg[0].tis";
connectAttr "j_neck_parentConstraint1.w0" "j_neck_parentConstraint1.tg[0].tw";
connectAttr "j_spine_03.s" "j_l_clavicle.is";
connectAttr "j_l_clavicle_parentConstraint1.ctx" "j_l_clavicle.tx";
connectAttr "j_l_clavicle_parentConstraint1.cty" "j_l_clavicle.ty";
connectAttr "j_l_clavicle_parentConstraint1.ctz" "j_l_clavicle.tz";
connectAttr "j_l_clavicle_parentConstraint1.crx" "j_l_clavicle.rx";
connectAttr "j_l_clavicle_parentConstraint1.cry" "j_l_clavicle.ry";
connectAttr "j_l_clavicle_parentConstraint1.crz" "j_l_clavicle.rz";
connectAttr "skeleton.di" "j_l_clavicle.do";
connectAttr "j_l_clavicle.s" "j_l_shoulder.is";
connectAttr "j_l_shoulder_parentConstraint1.ctx" "j_l_shoulder.tx";
connectAttr "j_l_shoulder_parentConstraint1.cty" "j_l_shoulder.ty";
connectAttr "j_l_shoulder_parentConstraint1.ctz" "j_l_shoulder.tz";
connectAttr "j_l_shoulder_parentConstraint1.crx" "j_l_shoulder.rx";
connectAttr "j_l_shoulder_parentConstraint1.cry" "j_l_shoulder.ry";
connectAttr "j_l_shoulder_parentConstraint1.crz" "j_l_shoulder.rz";
connectAttr "skeleton.di" "j_l_shoulder.do";
connectAttr "j_l_shoulder.s" "j_l_elbow.is";
connectAttr "j_l_elbow_parentConstraint1.ctx" "j_l_elbow.tx";
connectAttr "j_l_elbow_parentConstraint1.cty" "j_l_elbow.ty";
connectAttr "j_l_elbow_parentConstraint1.ctz" "j_l_elbow.tz";
connectAttr "j_l_elbow_parentConstraint1.crx" "j_l_elbow.rx";
connectAttr "j_l_elbow_parentConstraint1.cry" "j_l_elbow.ry";
connectAttr "j_l_elbow_parentConstraint1.crz" "j_l_elbow.rz";
connectAttr "skeleton.di" "j_l_elbow.do";
connectAttr "j_l_elbow.s" "j_l_wrist.is";
connectAttr "j_l_wrist_parentConstraint1.ctx" "j_l_wrist.tx";
connectAttr "j_l_wrist_parentConstraint1.cty" "j_l_wrist.ty";
connectAttr "j_l_wrist_parentConstraint1.ctz" "j_l_wrist.tz";
connectAttr "j_l_wrist_parentConstraint1.crx" "j_l_wrist.rx";
connectAttr "j_l_wrist_parentConstraint1.cry" "j_l_wrist.ry";
connectAttr "j_l_wrist_parentConstraint1.crz" "j_l_wrist.rz";
connectAttr "skeleton.di" "j_l_wrist.do";
connectAttr "j_l_wrist.ro" "j_l_wrist_parentConstraint1.cro";
connectAttr "j_l_wrist.pim" "j_l_wrist_parentConstraint1.cpim";
connectAttr "j_l_wrist.rp" "j_l_wrist_parentConstraint1.crp";
connectAttr "j_l_wrist.rpt" "j_l_wrist_parentConstraint1.crt";
connectAttr "j_l_wrist.jo" "j_l_wrist_parentConstraint1.cjo";
connectAttr "ctrl_j_l_wrist.t" "j_l_wrist_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_wrist.rp" "j_l_wrist_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_wrist.rpt" "j_l_wrist_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_wrist.r" "j_l_wrist_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_wrist.ro" "j_l_wrist_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_wrist.s" "j_l_wrist_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_wrist.pm" "j_l_wrist_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_wrist.jo" "j_l_wrist_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_wrist.ssc" "j_l_wrist_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_wrist.is" "j_l_wrist_parentConstraint1.tg[0].tis";
connectAttr "j_l_wrist_parentConstraint1.w0" "j_l_wrist_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_wrist_parentConstraint1.do";
connectAttr "j_l_elbow.ro" "j_l_elbow_parentConstraint1.cro";
connectAttr "j_l_elbow.pim" "j_l_elbow_parentConstraint1.cpim";
connectAttr "j_l_elbow.rp" "j_l_elbow_parentConstraint1.crp";
connectAttr "j_l_elbow.rpt" "j_l_elbow_parentConstraint1.crt";
connectAttr "j_l_elbow.jo" "j_l_elbow_parentConstraint1.cjo";
connectAttr "ctrl_j_l_elbow.t" "j_l_elbow_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_elbow.rp" "j_l_elbow_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_elbow.rpt" "j_l_elbow_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_elbow.r" "j_l_elbow_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_elbow.ro" "j_l_elbow_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_elbow.s" "j_l_elbow_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_elbow.pm" "j_l_elbow_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_elbow.jo" "j_l_elbow_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_elbow.ssc" "j_l_elbow_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_elbow.is" "j_l_elbow_parentConstraint1.tg[0].tis";
connectAttr "j_l_elbow_parentConstraint1.w0" "j_l_elbow_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_elbow_parentConstraint1.do";
connectAttr "j_l_shoulder.ro" "j_l_shoulder_parentConstraint1.cro";
connectAttr "j_l_shoulder.pim" "j_l_shoulder_parentConstraint1.cpim";
connectAttr "j_l_shoulder.rp" "j_l_shoulder_parentConstraint1.crp";
connectAttr "j_l_shoulder.rpt" "j_l_shoulder_parentConstraint1.crt";
connectAttr "j_l_shoulder.jo" "j_l_shoulder_parentConstraint1.cjo";
connectAttr "ctrl_j_l_shoulder.t" "j_l_shoulder_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_shoulder.rp" "j_l_shoulder_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_shoulder.rpt" "j_l_shoulder_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_shoulder.r" "j_l_shoulder_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_shoulder.ro" "j_l_shoulder_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_shoulder.s" "j_l_shoulder_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_shoulder.pm" "j_l_shoulder_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_shoulder.jo" "j_l_shoulder_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_shoulder.ssc" "j_l_shoulder_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_shoulder.is" "j_l_shoulder_parentConstraint1.tg[0].tis";
connectAttr "j_l_shoulder_parentConstraint1.w0" "j_l_shoulder_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_shoulder_parentConstraint1.do";
connectAttr "j_l_clavicle.ro" "j_l_clavicle_parentConstraint1.cro";
connectAttr "j_l_clavicle.pim" "j_l_clavicle_parentConstraint1.cpim";
connectAttr "j_l_clavicle.rp" "j_l_clavicle_parentConstraint1.crp";
connectAttr "j_l_clavicle.rpt" "j_l_clavicle_parentConstraint1.crt";
connectAttr "j_l_clavicle.jo" "j_l_clavicle_parentConstraint1.cjo";
connectAttr "ctrl_j_l_clavicle.t" "j_l_clavicle_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_clavicle.rp" "j_l_clavicle_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_clavicle.rpt" "j_l_clavicle_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_clavicle.r" "j_l_clavicle_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_clavicle.ro" "j_l_clavicle_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_clavicle.s" "j_l_clavicle_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_clavicle.pm" "j_l_clavicle_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_clavicle.jo" "j_l_clavicle_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_clavicle.ssc" "j_l_clavicle_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_clavicle.is" "j_l_clavicle_parentConstraint1.tg[0].tis";
connectAttr "j_l_clavicle_parentConstraint1.w0" "j_l_clavicle_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_clavicle_parentConstraint1.do";
connectAttr "j_spine_03.s" "j_r_clavicle.is";
connectAttr "j_r_clavicle_parentConstraint1.ctx" "j_r_clavicle.tx";
connectAttr "j_r_clavicle_parentConstraint1.cty" "j_r_clavicle.ty";
connectAttr "j_r_clavicle_parentConstraint1.ctz" "j_r_clavicle.tz";
connectAttr "j_r_clavicle_parentConstraint1.crx" "j_r_clavicle.rx";
connectAttr "j_r_clavicle_parentConstraint1.cry" "j_r_clavicle.ry";
connectAttr "j_r_clavicle_parentConstraint1.crz" "j_r_clavicle.rz";
connectAttr "skeleton.di" "j_r_clavicle.do";
connectAttr "j_r_clavicle.s" "j_r_shoulder.is";
connectAttr "j_r_shoulder_parentConstraint1.ctx" "j_r_shoulder.tx";
connectAttr "j_r_shoulder_parentConstraint1.cty" "j_r_shoulder.ty";
connectAttr "j_r_shoulder_parentConstraint1.ctz" "j_r_shoulder.tz";
connectAttr "j_r_shoulder_parentConstraint1.crx" "j_r_shoulder.rx";
connectAttr "j_r_shoulder_parentConstraint1.cry" "j_r_shoulder.ry";
connectAttr "j_r_shoulder_parentConstraint1.crz" "j_r_shoulder.rz";
connectAttr "skeleton.di" "j_r_shoulder.do";
connectAttr "j_r_shoulder.s" "j_r_elbow.is";
connectAttr "j_r_elbow_parentConstraint1.ctx" "j_r_elbow.tx";
connectAttr "j_r_elbow_parentConstraint1.cty" "j_r_elbow.ty";
connectAttr "j_r_elbow_parentConstraint1.ctz" "j_r_elbow.tz";
connectAttr "j_r_elbow_parentConstraint1.crx" "j_r_elbow.rx";
connectAttr "j_r_elbow_parentConstraint1.cry" "j_r_elbow.ry";
connectAttr "j_r_elbow_parentConstraint1.crz" "j_r_elbow.rz";
connectAttr "skeleton.di" "j_r_elbow.do";
connectAttr "j_r_elbow.s" "j_r_wrist.is";
connectAttr "j_r_wrist_parentConstraint1.ctx" "j_r_wrist.tx";
connectAttr "j_r_wrist_parentConstraint1.cty" "j_r_wrist.ty";
connectAttr "j_r_wrist_parentConstraint1.ctz" "j_r_wrist.tz";
connectAttr "j_r_wrist_parentConstraint1.crx" "j_r_wrist.rx";
connectAttr "j_r_wrist_parentConstraint1.cry" "j_r_wrist.ry";
connectAttr "j_r_wrist_parentConstraint1.crz" "j_r_wrist.rz";
connectAttr "skeleton.di" "j_r_wrist.do";
connectAttr "j_r_wrist.ro" "j_r_wrist_parentConstraint1.cro";
connectAttr "j_r_wrist.pim" "j_r_wrist_parentConstraint1.cpim";
connectAttr "j_r_wrist.rp" "j_r_wrist_parentConstraint1.crp";
connectAttr "j_r_wrist.rpt" "j_r_wrist_parentConstraint1.crt";
connectAttr "j_r_wrist.jo" "j_r_wrist_parentConstraint1.cjo";
connectAttr "ctrl_j_r_wrist.t" "j_r_wrist_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_wrist.rp" "j_r_wrist_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_wrist.rpt" "j_r_wrist_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_wrist.r" "j_r_wrist_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_wrist.ro" "j_r_wrist_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_wrist.s" "j_r_wrist_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_wrist.pm" "j_r_wrist_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_wrist.jo" "j_r_wrist_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_wrist.ssc" "j_r_wrist_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_wrist.is" "j_r_wrist_parentConstraint1.tg[0].tis";
connectAttr "j_r_wrist_parentConstraint1.w0" "j_r_wrist_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_wrist_parentConstraint1.do";
connectAttr "j_r_elbow.ro" "j_r_elbow_parentConstraint1.cro";
connectAttr "j_r_elbow.pim" "j_r_elbow_parentConstraint1.cpim";
connectAttr "j_r_elbow.rp" "j_r_elbow_parentConstraint1.crp";
connectAttr "j_r_elbow.rpt" "j_r_elbow_parentConstraint1.crt";
connectAttr "j_r_elbow.jo" "j_r_elbow_parentConstraint1.cjo";
connectAttr "ctrl_j_r_elbow.t" "j_r_elbow_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_elbow.rp" "j_r_elbow_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_elbow.rpt" "j_r_elbow_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_elbow.r" "j_r_elbow_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_elbow.ro" "j_r_elbow_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_elbow.s" "j_r_elbow_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_elbow.pm" "j_r_elbow_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_elbow.jo" "j_r_elbow_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_elbow.ssc" "j_r_elbow_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_elbow.is" "j_r_elbow_parentConstraint1.tg[0].tis";
connectAttr "j_r_elbow_parentConstraint1.w0" "j_r_elbow_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_elbow_parentConstraint1.do";
connectAttr "j_r_shoulder.ro" "j_r_shoulder_parentConstraint1.cro";
connectAttr "j_r_shoulder.pim" "j_r_shoulder_parentConstraint1.cpim";
connectAttr "j_r_shoulder.rp" "j_r_shoulder_parentConstraint1.crp";
connectAttr "j_r_shoulder.rpt" "j_r_shoulder_parentConstraint1.crt";
connectAttr "j_r_shoulder.jo" "j_r_shoulder_parentConstraint1.cjo";
connectAttr "ctrl_j_r_shoulder.t" "j_r_shoulder_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_shoulder.rp" "j_r_shoulder_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_shoulder.rpt" "j_r_shoulder_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_shoulder.r" "j_r_shoulder_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_shoulder.ro" "j_r_shoulder_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_shoulder.s" "j_r_shoulder_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_shoulder.pm" "j_r_shoulder_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_shoulder.jo" "j_r_shoulder_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_shoulder.ssc" "j_r_shoulder_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_shoulder.is" "j_r_shoulder_parentConstraint1.tg[0].tis";
connectAttr "j_r_shoulder_parentConstraint1.w0" "j_r_shoulder_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_shoulder_parentConstraint1.do";
connectAttr "j_r_clavicle.ro" "j_r_clavicle_parentConstraint1.cro";
connectAttr "j_r_clavicle.pim" "j_r_clavicle_parentConstraint1.cpim";
connectAttr "j_r_clavicle.rp" "j_r_clavicle_parentConstraint1.crp";
connectAttr "j_r_clavicle.rpt" "j_r_clavicle_parentConstraint1.crt";
connectAttr "j_r_clavicle.jo" "j_r_clavicle_parentConstraint1.cjo";
connectAttr "ctrl_j_r_clavicle.t" "j_r_clavicle_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_clavicle.rp" "j_r_clavicle_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_clavicle.rpt" "j_r_clavicle_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_clavicle.r" "j_r_clavicle_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_clavicle.ro" "j_r_clavicle_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_clavicle.s" "j_r_clavicle_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_clavicle.pm" "j_r_clavicle_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_clavicle.jo" "j_r_clavicle_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_clavicle.ssc" "j_r_clavicle_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_clavicle.is" "j_r_clavicle_parentConstraint1.tg[0].tis";
connectAttr "j_r_clavicle_parentConstraint1.w0" "j_r_clavicle_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_clavicle_parentConstraint1.do";
connectAttr "j_spine_03.ro" "j_spine_03_parentConstraint1.cro";
connectAttr "j_spine_03.pim" "j_spine_03_parentConstraint1.cpim";
connectAttr "j_spine_03.rp" "j_spine_03_parentConstraint1.crp";
connectAttr "j_spine_03.rpt" "j_spine_03_parentConstraint1.crt";
connectAttr "j_spine_03.jo" "j_spine_03_parentConstraint1.cjo";
connectAttr "ctrl_j_spine_03.t" "j_spine_03_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_spine_03.rp" "j_spine_03_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_spine_03.rpt" "j_spine_03_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_spine_03.r" "j_spine_03_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_spine_03.ro" "j_spine_03_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_spine_03.s" "j_spine_03_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_spine_03.pm" "j_spine_03_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_spine_03.jo" "j_spine_03_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_spine_03.ssc" "j_spine_03_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_spine_03.is" "j_spine_03_parentConstraint1.tg[0].tis";
connectAttr "j_spine_03_parentConstraint1.w0" "j_spine_03_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_spine_03_parentConstraint1.do";
connectAttr "j_spine_02.ro" "j_spine_02_parentConstraint1.cro";
connectAttr "j_spine_02.pim" "j_spine_02_parentConstraint1.cpim";
connectAttr "j_spine_02.rp" "j_spine_02_parentConstraint1.crp";
connectAttr "j_spine_02.rpt" "j_spine_02_parentConstraint1.crt";
connectAttr "j_spine_02.jo" "j_spine_02_parentConstraint1.cjo";
connectAttr "ctrl_j_spine_02.t" "j_spine_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_spine_02.rp" "j_spine_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_spine_02.rpt" "j_spine_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_spine_02.r" "j_spine_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_spine_02.ro" "j_spine_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_spine_02.s" "j_spine_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_spine_02.pm" "j_spine_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_spine_02.jo" "j_spine_02_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_spine_02.ssc" "j_spine_02_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_spine_02.is" "j_spine_02_parentConstraint1.tg[0].tis";
connectAttr "j_spine_02_parentConstraint1.w0" "j_spine_02_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_spine_02_parentConstraint1.do";
connectAttr "j_spine_01.s" "j_tail_01.is";
connectAttr "j_tail_01_parentConstraint1.ctx" "j_tail_01.tx";
connectAttr "j_tail_01_parentConstraint1.cty" "j_tail_01.ty";
connectAttr "j_tail_01_parentConstraint1.ctz" "j_tail_01.tz";
connectAttr "j_tail_01_parentConstraint1.crx" "j_tail_01.rx";
connectAttr "j_tail_01_parentConstraint1.cry" "j_tail_01.ry";
connectAttr "j_tail_01_parentConstraint1.crz" "j_tail_01.rz";
connectAttr "skeleton.di" "j_tail_01.do";
connectAttr "j_tail_01.s" "j_tail_02.is";
connectAttr "j_tail_02_parentConstraint1.ctx" "j_tail_02.tx";
connectAttr "j_tail_02_parentConstraint1.cty" "j_tail_02.ty";
connectAttr "j_tail_02_parentConstraint1.ctz" "j_tail_02.tz";
connectAttr "j_tail_02_parentConstraint1.crx" "j_tail_02.rx";
connectAttr "j_tail_02_parentConstraint1.cry" "j_tail_02.ry";
connectAttr "j_tail_02_parentConstraint1.crz" "j_tail_02.rz";
connectAttr "skeleton.di" "j_tail_02.do";
connectAttr "j_tail_02.s" "j_tail_03.is";
connectAttr "j_tail_03_parentConstraint1.ctx" "j_tail_03.tx";
connectAttr "j_tail_03_parentConstraint1.cty" "j_tail_03.ty";
connectAttr "j_tail_03_parentConstraint1.ctz" "j_tail_03.tz";
connectAttr "j_tail_03_parentConstraint1.crx" "j_tail_03.rx";
connectAttr "j_tail_03_parentConstraint1.cry" "j_tail_03.ry";
connectAttr "j_tail_03_parentConstraint1.crz" "j_tail_03.rz";
connectAttr "skeleton.di" "j_tail_03.do";
connectAttr "j_tail_03.s" "j_tail_04.is";
connectAttr "j_tail_04_parentConstraint1.ctx" "j_tail_04.tx";
connectAttr "j_tail_04_parentConstraint1.cty" "j_tail_04.ty";
connectAttr "j_tail_04_parentConstraint1.ctz" "j_tail_04.tz";
connectAttr "j_tail_04_parentConstraint1.crx" "j_tail_04.rx";
connectAttr "j_tail_04_parentConstraint1.cry" "j_tail_04.ry";
connectAttr "j_tail_04_parentConstraint1.crz" "j_tail_04.rz";
connectAttr "skeleton.di" "j_tail_04.do";
connectAttr "j_tail_04.s" "j_tail_05.is";
connectAttr "j_tail_05_parentConstraint1.ctx" "j_tail_05.tx";
connectAttr "j_tail_05_parentConstraint1.cty" "j_tail_05.ty";
connectAttr "j_tail_05_parentConstraint1.ctz" "j_tail_05.tz";
connectAttr "j_tail_05_parentConstraint1.crx" "j_tail_05.rx";
connectAttr "j_tail_05_parentConstraint1.cry" "j_tail_05.ry";
connectAttr "j_tail_05_parentConstraint1.crz" "j_tail_05.rz";
connectAttr "skeleton.di" "j_tail_05.do";
connectAttr "j_tail_05.ro" "j_tail_05_parentConstraint1.cro";
connectAttr "j_tail_05.pim" "j_tail_05_parentConstraint1.cpim";
connectAttr "j_tail_05.rp" "j_tail_05_parentConstraint1.crp";
connectAttr "j_tail_05.rpt" "j_tail_05_parentConstraint1.crt";
connectAttr "j_tail_05.jo" "j_tail_05_parentConstraint1.cjo";
connectAttr "ctrl_j_tail_05.t" "j_tail_05_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_tail_05.rp" "j_tail_05_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_tail_05.rpt" "j_tail_05_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_tail_05.r" "j_tail_05_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_tail_05.ro" "j_tail_05_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_tail_05.s" "j_tail_05_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_tail_05.pm" "j_tail_05_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_05.jo" "j_tail_05_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_tail_05.ssc" "j_tail_05_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_tail_05.is" "j_tail_05_parentConstraint1.tg[0].tis";
connectAttr "j_tail_05_parentConstraint1.w0" "j_tail_05_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_tail_05_parentConstraint1.do";
connectAttr "j_tail_04.ro" "j_tail_04_parentConstraint1.cro";
connectAttr "j_tail_04.pim" "j_tail_04_parentConstraint1.cpim";
connectAttr "j_tail_04.rp" "j_tail_04_parentConstraint1.crp";
connectAttr "j_tail_04.rpt" "j_tail_04_parentConstraint1.crt";
connectAttr "j_tail_04.jo" "j_tail_04_parentConstraint1.cjo";
connectAttr "ctrl_j_tail_04.t" "j_tail_04_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_tail_04.rp" "j_tail_04_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_tail_04.rpt" "j_tail_04_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_tail_04.r" "j_tail_04_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_tail_04.ro" "j_tail_04_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_tail_04.s" "j_tail_04_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_tail_04.pm" "j_tail_04_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_04.jo" "j_tail_04_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_tail_04.ssc" "j_tail_04_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_tail_04.is" "j_tail_04_parentConstraint1.tg[0].tis";
connectAttr "j_tail_04_parentConstraint1.w0" "j_tail_04_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_tail_04_parentConstraint1.do";
connectAttr "j_tail_03.ro" "j_tail_03_parentConstraint1.cro";
connectAttr "j_tail_03.pim" "j_tail_03_parentConstraint1.cpim";
connectAttr "j_tail_03.rp" "j_tail_03_parentConstraint1.crp";
connectAttr "j_tail_03.rpt" "j_tail_03_parentConstraint1.crt";
connectAttr "j_tail_03.jo" "j_tail_03_parentConstraint1.cjo";
connectAttr "ctrl_j_tail_03.t" "j_tail_03_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_tail_03.rp" "j_tail_03_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_tail_03.rpt" "j_tail_03_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_tail_03.r" "j_tail_03_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_tail_03.ro" "j_tail_03_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_tail_03.s" "j_tail_03_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_tail_03.pm" "j_tail_03_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_03.jo" "j_tail_03_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_tail_03.ssc" "j_tail_03_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_tail_03.is" "j_tail_03_parentConstraint1.tg[0].tis";
connectAttr "j_tail_03_parentConstraint1.w0" "j_tail_03_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_tail_03_parentConstraint1.do";
connectAttr "j_tail_02.ro" "j_tail_02_parentConstraint1.cro";
connectAttr "j_tail_02.pim" "j_tail_02_parentConstraint1.cpim";
connectAttr "j_tail_02.rp" "j_tail_02_parentConstraint1.crp";
connectAttr "j_tail_02.rpt" "j_tail_02_parentConstraint1.crt";
connectAttr "j_tail_02.jo" "j_tail_02_parentConstraint1.cjo";
connectAttr "ctrl_j_tail_02.t" "j_tail_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_tail_02.rp" "j_tail_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_tail_02.rpt" "j_tail_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_tail_02.r" "j_tail_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_tail_02.ro" "j_tail_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_tail_02.s" "j_tail_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_tail_02.pm" "j_tail_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_02.jo" "j_tail_02_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_tail_02.ssc" "j_tail_02_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_tail_02.is" "j_tail_02_parentConstraint1.tg[0].tis";
connectAttr "j_tail_02_parentConstraint1.w0" "j_tail_02_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_tail_02_parentConstraint1.do";
connectAttr "j_tail_01.ro" "j_tail_01_parentConstraint1.cro";
connectAttr "j_tail_01.pim" "j_tail_01_parentConstraint1.cpim";
connectAttr "j_tail_01.rp" "j_tail_01_parentConstraint1.crp";
connectAttr "j_tail_01.rpt" "j_tail_01_parentConstraint1.crt";
connectAttr "j_tail_01.jo" "j_tail_01_parentConstraint1.cjo";
connectAttr "ctrl_j_tail_01.t" "j_tail_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_tail_01.rp" "j_tail_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_tail_01.rpt" "j_tail_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_tail_01.r" "j_tail_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_tail_01.ro" "j_tail_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_tail_01.s" "j_tail_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_tail_01.pm" "j_tail_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_01.jo" "j_tail_01_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_tail_01.ssc" "j_tail_01_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_tail_01.is" "j_tail_01_parentConstraint1.tg[0].tis";
connectAttr "j_tail_01_parentConstraint1.w0" "j_tail_01_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_tail_01_parentConstraint1.do";
connectAttr "j_spine_01.ro" "j_spine_01_parentConstraint1.cro";
connectAttr "j_spine_01.pim" "j_spine_01_parentConstraint1.cpim";
connectAttr "j_spine_01.rp" "j_spine_01_parentConstraint1.crp";
connectAttr "j_spine_01.rpt" "j_spine_01_parentConstraint1.crt";
connectAttr "j_spine_01.jo" "j_spine_01_parentConstraint1.cjo";
connectAttr "ctrl_j_spine_01.t" "j_spine_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_spine_01.rp" "j_spine_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_spine_01.rpt" "j_spine_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_spine_01.r" "j_spine_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_spine_01.ro" "j_spine_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_spine_01.s" "j_spine_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_spine_01.pm" "j_spine_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_spine_01.jo" "j_spine_01_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_spine_01.ssc" "j_spine_01_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_spine_01.is" "j_spine_01_parentConstraint1.tg[0].tis";
connectAttr "j_spine_01_parentConstraint1.w0" "j_spine_01_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_pelvis.t" "j_spine_01_parentConstraint1.tg[1].tt";
connectAttr "ctrl_j_pelvis.rp" "j_spine_01_parentConstraint1.tg[1].trp";
connectAttr "ctrl_j_pelvis.rpt" "j_spine_01_parentConstraint1.tg[1].trt";
connectAttr "ctrl_j_pelvis.r" "j_spine_01_parentConstraint1.tg[1].tr";
connectAttr "ctrl_j_pelvis.ro" "j_spine_01_parentConstraint1.tg[1].tro";
connectAttr "ctrl_j_pelvis.s" "j_spine_01_parentConstraint1.tg[1].ts";
connectAttr "ctrl_j_pelvis.pm" "j_spine_01_parentConstraint1.tg[1].tpm";
connectAttr "ctrl_j_pelvis.jo" "j_spine_01_parentConstraint1.tg[1].tjo";
connectAttr "ctrl_j_pelvis.ssc" "j_spine_01_parentConstraint1.tg[1].tsc";
connectAttr "ctrl_j_pelvis.is" "j_spine_01_parentConstraint1.tg[1].tis";
connectAttr "j_spine_01_parentConstraint1.w1" "j_spine_01_parentConstraint1.tg[1].tw"
		;
connectAttr "skeleton.di" "j_spine_01_parentConstraint1.do";
connectAttr "j_pelvis.s" "j_l_femur.is";
connectAttr "j_l_femur_parentConstraint1.ctx" "j_l_femur.tx";
connectAttr "j_l_femur_parentConstraint1.cty" "j_l_femur.ty";
connectAttr "j_l_femur_parentConstraint1.ctz" "j_l_femur.tz";
connectAttr "j_l_femur_parentConstraint1.crx" "j_l_femur.rx";
connectAttr "j_l_femur_parentConstraint1.cry" "j_l_femur.ry";
connectAttr "j_l_femur_parentConstraint1.crz" "j_l_femur.rz";
connectAttr "skeleton.di" "j_l_femur.do";
connectAttr "j_l_femur.s" "j_l_knee.is";
connectAttr "j_l_knee_parentConstraint1.ctx" "j_l_knee.tx";
connectAttr "j_l_knee_parentConstraint1.cty" "j_l_knee.ty";
connectAttr "j_l_knee_parentConstraint1.ctz" "j_l_knee.tz";
connectAttr "j_l_knee_parentConstraint1.crx" "j_l_knee.rx";
connectAttr "j_l_knee_parentConstraint1.cry" "j_l_knee.ry";
connectAttr "j_l_knee_parentConstraint1.crz" "j_l_knee.rz";
connectAttr "skeleton.di" "j_l_knee.do";
connectAttr "j_l_knee.s" "j_l_heel.is";
connectAttr "j_l_heel_parentConstraint1.ctx" "j_l_heel.tx";
connectAttr "j_l_heel_parentConstraint1.cty" "j_l_heel.ty";
connectAttr "j_l_heel_parentConstraint1.ctz" "j_l_heel.tz";
connectAttr "j_l_heel_parentConstraint1.crx" "j_l_heel.rx";
connectAttr "j_l_heel_parentConstraint1.cry" "j_l_heel.ry";
connectAttr "j_l_heel_parentConstraint1.crz" "j_l_heel.rz";
connectAttr "skeleton.di" "j_l_heel.do";
connectAttr "j_l_heel.s" "j_l_foot.is";
connectAttr "j_l_foot_parentConstraint1.ctx" "j_l_foot.tx";
connectAttr "j_l_foot_parentConstraint1.cty" "j_l_foot.ty";
connectAttr "j_l_foot_parentConstraint1.ctz" "j_l_foot.tz";
connectAttr "j_l_foot_parentConstraint1.crx" "j_l_foot.rx";
connectAttr "j_l_foot_parentConstraint1.cry" "j_l_foot.ry";
connectAttr "j_l_foot_parentConstraint1.crz" "j_l_foot.rz";
connectAttr "skeleton.di" "j_l_foot.do";
connectAttr "j_l_foot.s" "j_l_toe.is";
connectAttr "j_l_toe_parentConstraint1.ctx" "j_l_toe.tx";
connectAttr "j_l_toe_parentConstraint1.cty" "j_l_toe.ty";
connectAttr "j_l_toe_parentConstraint1.ctz" "j_l_toe.tz";
connectAttr "j_l_toe_parentConstraint1.crx" "j_l_toe.rx";
connectAttr "j_l_toe_parentConstraint1.cry" "j_l_toe.ry";
connectAttr "j_l_toe_parentConstraint1.crz" "j_l_toe.rz";
connectAttr "skeleton.di" "j_l_toe.do";
connectAttr "j_l_toe.ro" "j_l_toe_parentConstraint1.cro";
connectAttr "j_l_toe.pim" "j_l_toe_parentConstraint1.cpim";
connectAttr "j_l_toe.rp" "j_l_toe_parentConstraint1.crp";
connectAttr "j_l_toe.rpt" "j_l_toe_parentConstraint1.crt";
connectAttr "j_l_toe.jo" "j_l_toe_parentConstraint1.cjo";
connectAttr "ctrl_j_l_toe.t" "j_l_toe_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_toe.rp" "j_l_toe_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_toe.rpt" "j_l_toe_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_toe.r" "j_l_toe_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_toe.ro" "j_l_toe_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_toe.s" "j_l_toe_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_toe.pm" "j_l_toe_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_toe.jo" "j_l_toe_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_toe.ssc" "j_l_toe_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_toe.is" "j_l_toe_parentConstraint1.tg[0].tis";
connectAttr "j_l_toe_parentConstraint1.w0" "j_l_toe_parentConstraint1.tg[0].tw";
connectAttr "skeleton.di" "j_l_toe_parentConstraint1.do";
connectAttr "j_l_foot.ro" "j_l_foot_parentConstraint1.cro";
connectAttr "j_l_foot.pim" "j_l_foot_parentConstraint1.cpim";
connectAttr "j_l_foot.rp" "j_l_foot_parentConstraint1.crp";
connectAttr "j_l_foot.rpt" "j_l_foot_parentConstraint1.crt";
connectAttr "j_l_foot.jo" "j_l_foot_parentConstraint1.cjo";
connectAttr "ctrl_j_l_foot.t" "j_l_foot_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_foot.rp" "j_l_foot_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_foot.rpt" "j_l_foot_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_foot.r" "j_l_foot_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_foot.ro" "j_l_foot_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_foot.s" "j_l_foot_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_foot.pm" "j_l_foot_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_foot.jo" "j_l_foot_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_foot.ssc" "j_l_foot_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_foot.is" "j_l_foot_parentConstraint1.tg[0].tis";
connectAttr "j_l_foot_parentConstraint1.w0" "j_l_foot_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_foot_parentConstraint1.do";
connectAttr "j_l_heel.ro" "j_l_heel_parentConstraint1.cro";
connectAttr "j_l_heel.pim" "j_l_heel_parentConstraint1.cpim";
connectAttr "j_l_heel.rp" "j_l_heel_parentConstraint1.crp";
connectAttr "j_l_heel.rpt" "j_l_heel_parentConstraint1.crt";
connectAttr "j_l_heel.jo" "j_l_heel_parentConstraint1.cjo";
connectAttr "ctrl_j_l_heel.t" "j_l_heel_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_heel.rp" "j_l_heel_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_heel.rpt" "j_l_heel_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_heel.r" "j_l_heel_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_heel.ro" "j_l_heel_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_heel.s" "j_l_heel_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_heel.pm" "j_l_heel_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_heel.jo" "j_l_heel_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_heel.ssc" "j_l_heel_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_heel.is" "j_l_heel_parentConstraint1.tg[0].tis";
connectAttr "j_l_heel_parentConstraint1.w0" "j_l_heel_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_heel_parentConstraint1.do";
connectAttr "j_l_knee.ro" "j_l_knee_parentConstraint1.cro";
connectAttr "j_l_knee.pim" "j_l_knee_parentConstraint1.cpim";
connectAttr "j_l_knee.rp" "j_l_knee_parentConstraint1.crp";
connectAttr "j_l_knee.rpt" "j_l_knee_parentConstraint1.crt";
connectAttr "j_l_knee.jo" "j_l_knee_parentConstraint1.cjo";
connectAttr "ctrl_j_l_knee.t" "j_l_knee_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_knee.rp" "j_l_knee_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_knee.rpt" "j_l_knee_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_knee.r" "j_l_knee_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_knee.ro" "j_l_knee_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_knee.s" "j_l_knee_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_knee.pm" "j_l_knee_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_knee.jo" "j_l_knee_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_knee.ssc" "j_l_knee_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_knee.is" "j_l_knee_parentConstraint1.tg[0].tis";
connectAttr "j_l_knee_parentConstraint1.w0" "j_l_knee_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_knee_parentConstraint1.do";
connectAttr "j_l_femur.ro" "j_l_femur_parentConstraint1.cro";
connectAttr "j_l_femur.pim" "j_l_femur_parentConstraint1.cpim";
connectAttr "j_l_femur.rp" "j_l_femur_parentConstraint1.crp";
connectAttr "j_l_femur.rpt" "j_l_femur_parentConstraint1.crt";
connectAttr "j_l_femur.jo" "j_l_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_l_femur.t" "j_l_femur_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_l_femur.rp" "j_l_femur_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_l_femur.rpt" "j_l_femur_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_l_femur.r" "j_l_femur_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_l_femur.ro" "j_l_femur_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_l_femur.s" "j_l_femur_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_l_femur.pm" "j_l_femur_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_femur.jo" "j_l_femur_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_l_femur.ssc" "j_l_femur_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_l_femur.is" "j_l_femur_parentConstraint1.tg[0].tis";
connectAttr "j_l_femur_parentConstraint1.w0" "j_l_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_l_femur_parentConstraint1.do";
connectAttr "j_pelvis.s" "j_r_femur.is";
connectAttr "j_r_femur_parentConstraint1.ctx" "j_r_femur.tx";
connectAttr "j_r_femur_parentConstraint1.cty" "j_r_femur.ty";
connectAttr "j_r_femur_parentConstraint1.ctz" "j_r_femur.tz";
connectAttr "j_r_femur_parentConstraint1.crx" "j_r_femur.rx";
connectAttr "j_r_femur_parentConstraint1.cry" "j_r_femur.ry";
connectAttr "j_r_femur_parentConstraint1.crz" "j_r_femur.rz";
connectAttr "skeleton.di" "j_r_femur.do";
connectAttr "j_r_femur.s" "j_r_knee.is";
connectAttr "j_r_knee_parentConstraint1.ctx" "j_r_knee.tx";
connectAttr "j_r_knee_parentConstraint1.cty" "j_r_knee.ty";
connectAttr "j_r_knee_parentConstraint1.ctz" "j_r_knee.tz";
connectAttr "j_r_knee_parentConstraint1.crx" "j_r_knee.rx";
connectAttr "j_r_knee_parentConstraint1.cry" "j_r_knee.ry";
connectAttr "j_r_knee_parentConstraint1.crz" "j_r_knee.rz";
connectAttr "skeleton.di" "j_r_knee.do";
connectAttr "j_r_knee.s" "j_r_heel.is";
connectAttr "j_r_heel_parentConstraint1.ctx" "j_r_heel.tx";
connectAttr "j_r_heel_parentConstraint1.cty" "j_r_heel.ty";
connectAttr "j_r_heel_parentConstraint1.ctz" "j_r_heel.tz";
connectAttr "j_r_heel_parentConstraint1.crx" "j_r_heel.rx";
connectAttr "j_r_heel_parentConstraint1.cry" "j_r_heel.ry";
connectAttr "j_r_heel_parentConstraint1.crz" "j_r_heel.rz";
connectAttr "skeleton.di" "j_r_heel.do";
connectAttr "j_r_heel.s" "j_r_foot.is";
connectAttr "j_r_foot_parentConstraint1.ctx" "j_r_foot.tx";
connectAttr "j_r_foot_parentConstraint1.cty" "j_r_foot.ty";
connectAttr "j_r_foot_parentConstraint1.ctz" "j_r_foot.tz";
connectAttr "j_r_foot_parentConstraint1.crx" "j_r_foot.rx";
connectAttr "j_r_foot_parentConstraint1.cry" "j_r_foot.ry";
connectAttr "j_r_foot_parentConstraint1.crz" "j_r_foot.rz";
connectAttr "skeleton.di" "j_r_foot.do";
connectAttr "j_r_foot.s" "j_r_toe.is";
connectAttr "j_r_toe_parentConstraint1.ctx" "j_r_toe.tx";
connectAttr "j_r_toe_parentConstraint1.cty" "j_r_toe.ty";
connectAttr "j_r_toe_parentConstraint1.ctz" "j_r_toe.tz";
connectAttr "j_r_toe_parentConstraint1.crx" "j_r_toe.rx";
connectAttr "j_r_toe_parentConstraint1.cry" "j_r_toe.ry";
connectAttr "j_r_toe_parentConstraint1.crz" "j_r_toe.rz";
connectAttr "skeleton.di" "j_r_toe.do";
connectAttr "j_r_toe.ro" "j_r_toe_parentConstraint1.cro";
connectAttr "j_r_toe.pim" "j_r_toe_parentConstraint1.cpim";
connectAttr "j_r_toe.rp" "j_r_toe_parentConstraint1.crp";
connectAttr "j_r_toe.rpt" "j_r_toe_parentConstraint1.crt";
connectAttr "j_r_toe.jo" "j_r_toe_parentConstraint1.cjo";
connectAttr "ctrl_j_r_toe.t" "j_r_toe_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_toe.rp" "j_r_toe_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_toe.rpt" "j_r_toe_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_toe.r" "j_r_toe_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_toe.ro" "j_r_toe_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_toe.s" "j_r_toe_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_toe.pm" "j_r_toe_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_toe.jo" "j_r_toe_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_toe.ssc" "j_r_toe_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_toe.is" "j_r_toe_parentConstraint1.tg[0].tis";
connectAttr "j_r_toe_parentConstraint1.w0" "j_r_toe_parentConstraint1.tg[0].tw";
connectAttr "skeleton.di" "j_r_toe_parentConstraint1.do";
connectAttr "j_r_foot.ro" "j_r_foot_parentConstraint1.cro";
connectAttr "j_r_foot.pim" "j_r_foot_parentConstraint1.cpim";
connectAttr "j_r_foot.rp" "j_r_foot_parentConstraint1.crp";
connectAttr "j_r_foot.rpt" "j_r_foot_parentConstraint1.crt";
connectAttr "j_r_foot.jo" "j_r_foot_parentConstraint1.cjo";
connectAttr "ctrl_j_r_foot.t" "j_r_foot_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_foot.rp" "j_r_foot_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_foot.rpt" "j_r_foot_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_foot.r" "j_r_foot_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_foot.ro" "j_r_foot_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_foot.s" "j_r_foot_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_foot.pm" "j_r_foot_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_foot.jo" "j_r_foot_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_foot.ssc" "j_r_foot_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_foot.is" "j_r_foot_parentConstraint1.tg[0].tis";
connectAttr "j_r_foot_parentConstraint1.w0" "j_r_foot_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_foot_parentConstraint1.do";
connectAttr "j_r_heel.ro" "j_r_heel_parentConstraint1.cro";
connectAttr "j_r_heel.pim" "j_r_heel_parentConstraint1.cpim";
connectAttr "j_r_heel.rp" "j_r_heel_parentConstraint1.crp";
connectAttr "j_r_heel.rpt" "j_r_heel_parentConstraint1.crt";
connectAttr "j_r_heel.jo" "j_r_heel_parentConstraint1.cjo";
connectAttr "ctrl_j_r_heel.t" "j_r_heel_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_heel.rp" "j_r_heel_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_heel.rpt" "j_r_heel_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_heel.r" "j_r_heel_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_heel.ro" "j_r_heel_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_heel.s" "j_r_heel_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_heel.pm" "j_r_heel_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_heel.jo" "j_r_heel_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_heel.ssc" "j_r_heel_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_heel.is" "j_r_heel_parentConstraint1.tg[0].tis";
connectAttr "j_r_heel_parentConstraint1.w0" "j_r_heel_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_heel_parentConstraint1.do";
connectAttr "j_r_knee.ro" "j_r_knee_parentConstraint1.cro";
connectAttr "j_r_knee.pim" "j_r_knee_parentConstraint1.cpim";
connectAttr "j_r_knee.rp" "j_r_knee_parentConstraint1.crp";
connectAttr "j_r_knee.rpt" "j_r_knee_parentConstraint1.crt";
connectAttr "j_r_knee.jo" "j_r_knee_parentConstraint1.cjo";
connectAttr "ctrl_j_r_knee.t" "j_r_knee_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_knee.rp" "j_r_knee_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_knee.rpt" "j_r_knee_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_knee.r" "j_r_knee_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_knee.ro" "j_r_knee_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_knee.s" "j_r_knee_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_knee.pm" "j_r_knee_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_knee.jo" "j_r_knee_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_knee.ssc" "j_r_knee_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_knee.is" "j_r_knee_parentConstraint1.tg[0].tis";
connectAttr "j_r_knee_parentConstraint1.w0" "j_r_knee_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_knee_parentConstraint1.do";
connectAttr "j_r_femur.ro" "j_r_femur_parentConstraint1.cro";
connectAttr "j_r_femur.pim" "j_r_femur_parentConstraint1.cpim";
connectAttr "j_r_femur.rp" "j_r_femur_parentConstraint1.crp";
connectAttr "j_r_femur.rpt" "j_r_femur_parentConstraint1.crt";
connectAttr "j_r_femur.jo" "j_r_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_r_femur.t" "j_r_femur_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_r_femur.rp" "j_r_femur_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_r_femur.rpt" "j_r_femur_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_r_femur.r" "j_r_femur_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_r_femur.ro" "j_r_femur_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_r_femur.s" "j_r_femur_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_r_femur.pm" "j_r_femur_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_femur.jo" "j_r_femur_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_r_femur.ssc" "j_r_femur_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_r_femur.is" "j_r_femur_parentConstraint1.tg[0].tis";
connectAttr "j_r_femur_parentConstraint1.w0" "j_r_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "skeleton.di" "j_r_femur_parentConstraint1.do";
connectAttr "j_pelvis.ro" "j_pelvis_parentConstraint1.cro";
connectAttr "j_pelvis.pim" "j_pelvis_parentConstraint1.cpim";
connectAttr "j_pelvis.rp" "j_pelvis_parentConstraint1.crp";
connectAttr "j_pelvis.rpt" "j_pelvis_parentConstraint1.crt";
connectAttr "j_pelvis.jo" "j_pelvis_parentConstraint1.cjo";
connectAttr "ctrl_j_pelvis_low.t" "j_pelvis_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_pelvis_low.rp" "j_pelvis_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_pelvis_low.rpt" "j_pelvis_parentConstraint1.tg[0].trt";
connectAttr "ctrl_j_pelvis_low.r" "j_pelvis_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_pelvis_low.ro" "j_pelvis_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_pelvis_low.s" "j_pelvis_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_pelvis_low.pm" "j_pelvis_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_pelvis_low.jo" "j_pelvis_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_pelvis_low.ssc" "j_pelvis_parentConstraint1.tg[0].tsc";
connectAttr "ctrl_j_pelvis_low.is" "j_pelvis_parentConstraint1.tg[0].tis";
connectAttr "j_pelvis_parentConstraint1.w0" "j_pelvis_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_pelvis.t" "j_pelvis_parentConstraint1.tg[1].tt";
connectAttr "ctrl_j_pelvis.rp" "j_pelvis_parentConstraint1.tg[1].trp";
connectAttr "ctrl_j_pelvis.rpt" "j_pelvis_parentConstraint1.tg[1].trt";
connectAttr "ctrl_j_pelvis.r" "j_pelvis_parentConstraint1.tg[1].tr";
connectAttr "ctrl_j_pelvis.ro" "j_pelvis_parentConstraint1.tg[1].tro";
connectAttr "ctrl_j_pelvis.s" "j_pelvis_parentConstraint1.tg[1].ts";
connectAttr "ctrl_j_pelvis.pm" "j_pelvis_parentConstraint1.tg[1].tpm";
connectAttr "ctrl_j_pelvis.jo" "j_pelvis_parentConstraint1.tg[1].tjo";
connectAttr "ctrl_j_pelvis.ssc" "j_pelvis_parentConstraint1.tg[1].tsc";
connectAttr "ctrl_j_pelvis.is" "j_pelvis_parentConstraint1.tg[1].tis";
connectAttr "j_pelvis_parentConstraint1.w1" "j_pelvis_parentConstraint1.tg[1].tw"
		;
connectAttr "skeleton.di" "j_pelvis_parentConstraint1.do";
connectAttr "makeNurbCircle9.oc" "ctrl_rootShape.cr";
connectAttr "makeNurbCircle10.oc" "ctrl_rootShape1.cr";
connectAttr "makeNurbCircle11.oc" "ctrl_rootShape2.cr";
connectAttr "makeNurbCircle1.oc" "ctrl_worldShape.cr";
connectAttr "prnt_cog_parentConstraint1.ctx" "prnt_cog.tx";
connectAttr "prnt_cog_parentConstraint1.cty" "prnt_cog.ty";
connectAttr "prnt_cog_parentConstraint1.ctz" "prnt_cog.tz";
connectAttr "prnt_cog_parentConstraint1.crx" "prnt_cog.rx";
connectAttr "prnt_cog_parentConstraint1.cry" "prnt_cog.ry";
connectAttr "prnt_cog_parentConstraint1.crz" "prnt_cog.rz";
connectAttr "prnt_cog.ro" "prnt_cog_parentConstraint1.cro";
connectAttr "prnt_cog.pim" "prnt_cog_parentConstraint1.cpim";
connectAttr "prnt_cog.rp" "prnt_cog_parentConstraint1.crp";
connectAttr "prnt_cog.rpt" "prnt_cog_parentConstraint1.crt";
connectAttr "ctrl_world.t" "prnt_cog_parentConstraint1.tg[0].tt";
connectAttr "ctrl_world.rp" "prnt_cog_parentConstraint1.tg[0].trp";
connectAttr "ctrl_world.rpt" "prnt_cog_parentConstraint1.tg[0].trt";
connectAttr "ctrl_world.r" "prnt_cog_parentConstraint1.tg[0].tr";
connectAttr "ctrl_world.ro" "prnt_cog_parentConstraint1.tg[0].tro";
connectAttr "ctrl_world.s" "prnt_cog_parentConstraint1.tg[0].ts";
connectAttr "ctrl_world.pm" "prnt_cog_parentConstraint1.tg[0].tpm";
connectAttr "prnt_cog_parentConstraint1.w0" "prnt_cog_parentConstraint1.tg[0].tw"
		;
connectAttr "spine.di" "ctrl_cog.do";
connectAttr "spine.di" "ctrl_pelvis.do";
connectAttr "groupId59.id" "ctrl_pelvisShape.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_pelvisShape.iog.og[0].gco";
connectAttr "spine.di" "ctrl_spine_01.do";
connectAttr "groupId17.id" "ctrl_spine_0Shape1.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_spine_0Shape1.iog.og[0].gco";
connectAttr "spine.di" "ctrl_spine_02.do";
connectAttr "groupId16.id" "ctrl_spine_0Shape2.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_spine_0Shape2.iog.og[0].gco";
connectAttr "spine.di" "ctrl_spine_03.do";
connectAttr "groupId15.id" "ctrl_spine_0Shape3.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_spine_0Shape3.iog.og[0].gco";
connectAttr "head.di" "ctrl_neck.do";
connectAttr "groupId66.id" "ctrl_neckShape.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_neckShape.iog.og[0].gco";
connectAttr "prnt_head_parentConstraint1.crx" "prnt_head.rx";
connectAttr "prnt_head_parentConstraint1.cry" "prnt_head.ry";
connectAttr "prnt_head_parentConstraint1.crz" "prnt_head.rz";
connectAttr "head.di" "ctrl_head.do";
connectAttr "groupId65.id" "ctrl_headShape.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_headShape.iog.og[0].gco";
connectAttr "right.di" "ctrl_r_ear_01.do";
connectAttr "groupId77.id" "ctrl_r_ear_0Shape1.iog.og[0].gid";
connectAttr "surfaceShader4SG.mwc" "ctrl_r_ear_0Shape1.iog.og[0].gco";
connectAttr "right.di" "ctrl_r_ear_02.do";
connectAttr "groupId78.id" "ctrl_r_ear_0Shape2.iog.og[0].gid";
connectAttr "surfaceShader4SG.mwc" "ctrl_r_ear_0Shape2.iog.og[0].gco";
connectAttr "left.di" "ctrl_l_ear_01.do";
connectAttr "groupId76.id" "ctrl_l_ear_0Shape1.iog.og[0].gid";
connectAttr "surfaceShader3SG.mwc" "ctrl_l_ear_0Shape1.iog.og[0].gco";
connectAttr "left.di" "ctrl_l_ear_02.do";
connectAttr "groupId75.id" "ctrl_l_ear_0Shape2.iog.og[0].gid";
connectAttr "surfaceShader3SG.mwc" "ctrl_l_ear_0Shape2.iog.og[0].gco";
connectAttr "prnt_head.ro" "prnt_head_parentConstraint1.cro";
connectAttr "prnt_head.pim" "prnt_head_parentConstraint1.cpim";
connectAttr "prnt_head.rp" "prnt_head_parentConstraint1.crp";
connectAttr "prnt_head.rpt" "prnt_head_parentConstraint1.crt";
connectAttr "ctrl_world.t" "prnt_head_parentConstraint1.tg[0].tt";
connectAttr "ctrl_world.rp" "prnt_head_parentConstraint1.tg[0].trp";
connectAttr "ctrl_world.rpt" "prnt_head_parentConstraint1.tg[0].trt";
connectAttr "ctrl_world.r" "prnt_head_parentConstraint1.tg[0].tr";
connectAttr "ctrl_world.ro" "prnt_head_parentConstraint1.tg[0].tro";
connectAttr "ctrl_world.s" "prnt_head_parentConstraint1.tg[0].ts";
connectAttr "ctrl_world.pm" "prnt_head_parentConstraint1.tg[0].tpm";
connectAttr "prnt_head_parentConstraint1.w0" "prnt_head_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_neck.t" "prnt_head_parentConstraint1.tg[1].tt";
connectAttr "ctrl_neck.rp" "prnt_head_parentConstraint1.tg[1].trp";
connectAttr "ctrl_neck.rpt" "prnt_head_parentConstraint1.tg[1].trt";
connectAttr "ctrl_neck.r" "prnt_head_parentConstraint1.tg[1].tr";
connectAttr "ctrl_neck.ro" "prnt_head_parentConstraint1.tg[1].tro";
connectAttr "ctrl_neck.s" "prnt_head_parentConstraint1.tg[1].ts";
connectAttr "ctrl_neck.pm" "prnt_head_parentConstraint1.tg[1].tpm";
connectAttr "prnt_head_parentConstraint1.w1" "prnt_head_parentConstraint1.tg[1].tw"
		;
connectAttr "ctrl_head.Follow" "prnt_head_parentConstraint1.w0";
connectAttr "rev_head_const.ox" "prnt_head_parentConstraint1.w1";
connectAttr "right.di" "ctrl_r_clavicle.do";
connectAttr "right.di" "ctrl_r_shoulder.do";
connectAttr "right.di" "ctrl_r_elbow.do";
connectAttr "right.di" "ctrl_r_wrist.do";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.ctx" "ctrl_j_r_clavicle.tx";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.cty" "ctrl_j_r_clavicle.ty";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.ctz" "ctrl_j_r_clavicle.tz";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.crx" "ctrl_j_r_clavicle.rx";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.cry" "ctrl_j_r_clavicle.ry";
connectAttr "ctrl_j_r_clavicle_parentConstraint1.crz" "ctrl_j_r_clavicle.rz";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.ctx" "ctrl_j_r_shoulder.tx";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.cty" "ctrl_j_r_shoulder.ty";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.ctz" "ctrl_j_r_shoulder.tz";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.crx" "ctrl_j_r_shoulder.rx";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.cry" "ctrl_j_r_shoulder.ry";
connectAttr "ctrl_j_r_shoulder_parentConstraint1.crz" "ctrl_j_r_shoulder.rz";
connectAttr "ctrl_j_r_clavicle.s" "ctrl_j_r_shoulder.is";
connectAttr "ctrl_j_r_elbow_parentConstraint1.ctx" "ctrl_j_r_elbow.tx";
connectAttr "ctrl_j_r_elbow_parentConstraint1.cty" "ctrl_j_r_elbow.ty";
connectAttr "ctrl_j_r_elbow_parentConstraint1.ctz" "ctrl_j_r_elbow.tz";
connectAttr "ctrl_j_r_elbow_parentConstraint1.crx" "ctrl_j_r_elbow.rx";
connectAttr "ctrl_j_r_elbow_parentConstraint1.cry" "ctrl_j_r_elbow.ry";
connectAttr "ctrl_j_r_elbow_parentConstraint1.crz" "ctrl_j_r_elbow.rz";
connectAttr "ctrl_j_r_shoulder.s" "ctrl_j_r_elbow.is";
connectAttr "ctrl_j_r_wrist_parentConstraint1.ctx" "ctrl_j_r_wrist.tx";
connectAttr "ctrl_j_r_wrist_parentConstraint1.cty" "ctrl_j_r_wrist.ty";
connectAttr "ctrl_j_r_wrist_parentConstraint1.ctz" "ctrl_j_r_wrist.tz";
connectAttr "ctrl_j_r_wrist_parentConstraint1.crx" "ctrl_j_r_wrist.rx";
connectAttr "ctrl_j_r_wrist_parentConstraint1.cry" "ctrl_j_r_wrist.ry";
connectAttr "ctrl_j_r_wrist_parentConstraint1.crz" "ctrl_j_r_wrist.rz";
connectAttr "ctrl_j_r_elbow.s" "ctrl_j_r_wrist.is";
connectAttr "ctrl_j_r_wrist.ro" "ctrl_j_r_wrist_parentConstraint1.cro";
connectAttr "ctrl_j_r_wrist.pim" "ctrl_j_r_wrist_parentConstraint1.cpim";
connectAttr "ctrl_j_r_wrist.rp" "ctrl_j_r_wrist_parentConstraint1.crp";
connectAttr "ctrl_j_r_wrist.rpt" "ctrl_j_r_wrist_parentConstraint1.crt";
connectAttr "ctrl_j_r_wrist.jo" "ctrl_j_r_wrist_parentConstraint1.cjo";
connectAttr "ctrl_r_wrist.t" "ctrl_j_r_wrist_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_wrist.rp" "ctrl_j_r_wrist_parentConstraint1.tg[0].trp";
connectAttr "ctrl_r_wrist.rpt" "ctrl_j_r_wrist_parentConstraint1.tg[0].trt";
connectAttr "ctrl_r_wrist.r" "ctrl_j_r_wrist_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_wrist.ro" "ctrl_j_r_wrist_parentConstraint1.tg[0].tro";
connectAttr "ctrl_r_wrist.s" "ctrl_j_r_wrist_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_wrist.pm" "ctrl_j_r_wrist_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_wrist_parentConstraint1.w0" "ctrl_j_r_wrist_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_elbow.ro" "ctrl_j_r_elbow_parentConstraint1.cro";
connectAttr "ctrl_j_r_elbow.pim" "ctrl_j_r_elbow_parentConstraint1.cpim";
connectAttr "ctrl_j_r_elbow.rp" "ctrl_j_r_elbow_parentConstraint1.crp";
connectAttr "ctrl_j_r_elbow.rpt" "ctrl_j_r_elbow_parentConstraint1.crt";
connectAttr "ctrl_j_r_elbow.jo" "ctrl_j_r_elbow_parentConstraint1.cjo";
connectAttr "ctrl_r_elbow.t" "ctrl_j_r_elbow_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_elbow.rp" "ctrl_j_r_elbow_parentConstraint1.tg[0].trp";
connectAttr "ctrl_r_elbow.rpt" "ctrl_j_r_elbow_parentConstraint1.tg[0].trt";
connectAttr "ctrl_r_elbow.r" "ctrl_j_r_elbow_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_elbow.ro" "ctrl_j_r_elbow_parentConstraint1.tg[0].tro";
connectAttr "ctrl_r_elbow.s" "ctrl_j_r_elbow_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_elbow.pm" "ctrl_j_r_elbow_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_elbow_parentConstraint1.w0" "ctrl_j_r_elbow_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_shoulder.ro" "ctrl_j_r_shoulder_parentConstraint1.cro";
connectAttr "ctrl_j_r_shoulder.pim" "ctrl_j_r_shoulder_parentConstraint1.cpim";
connectAttr "ctrl_j_r_shoulder.rp" "ctrl_j_r_shoulder_parentConstraint1.crp";
connectAttr "ctrl_j_r_shoulder.rpt" "ctrl_j_r_shoulder_parentConstraint1.crt";
connectAttr "ctrl_j_r_shoulder.jo" "ctrl_j_r_shoulder_parentConstraint1.cjo";
connectAttr "ctrl_r_shoulder.t" "ctrl_j_r_shoulder_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_shoulder.rp" "ctrl_j_r_shoulder_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_r_shoulder.rpt" "ctrl_j_r_shoulder_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_r_shoulder.r" "ctrl_j_r_shoulder_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_shoulder.ro" "ctrl_j_r_shoulder_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_r_shoulder.s" "ctrl_j_r_shoulder_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_shoulder.pm" "ctrl_j_r_shoulder_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_r_shoulder_parentConstraint1.w0" "ctrl_j_r_shoulder_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_clavicle.ro" "ctrl_j_r_clavicle_parentConstraint1.cro";
connectAttr "ctrl_j_r_clavicle.pim" "ctrl_j_r_clavicle_parentConstraint1.cpim";
connectAttr "ctrl_j_r_clavicle.rp" "ctrl_j_r_clavicle_parentConstraint1.crp";
connectAttr "ctrl_j_r_clavicle.rpt" "ctrl_j_r_clavicle_parentConstraint1.crt";
connectAttr "ctrl_j_r_clavicle.jo" "ctrl_j_r_clavicle_parentConstraint1.cjo";
connectAttr "ctrl_r_clavicle.t" "ctrl_j_r_clavicle_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_clavicle.rp" "ctrl_j_r_clavicle_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_r_clavicle.rpt" "ctrl_j_r_clavicle_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_r_clavicle.r" "ctrl_j_r_clavicle_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_clavicle.ro" "ctrl_j_r_clavicle_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_r_clavicle.s" "ctrl_j_r_clavicle_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_clavicle.pm" "ctrl_j_r_clavicle_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_r_clavicle_parentConstraint1.w0" "ctrl_j_r_clavicle_parentConstraint1.tg[0].tw"
		;
connectAttr "left.di" "ctrl_l_clavicle.do";
connectAttr "left.di" "ctrl_l_shoulder.do";
connectAttr "left.di" "ctrl_l_elbow.do";
connectAttr "left.di" "ctrl_l_wrist.do";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.ctx" "ctrl_j_l_clavicle.tx";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.cty" "ctrl_j_l_clavicle.ty";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.ctz" "ctrl_j_l_clavicle.tz";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.crx" "ctrl_j_l_clavicle.rx";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.cry" "ctrl_j_l_clavicle.ry";
connectAttr "ctrl_j_l_clavicle_parentConstraint1.crz" "ctrl_j_l_clavicle.rz";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.ctx" "ctrl_j_l_shoulder.tx";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.cty" "ctrl_j_l_shoulder.ty";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.ctz" "ctrl_j_l_shoulder.tz";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.crx" "ctrl_j_l_shoulder.rx";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.cry" "ctrl_j_l_shoulder.ry";
connectAttr "ctrl_j_l_shoulder_parentConstraint1.crz" "ctrl_j_l_shoulder.rz";
connectAttr "ctrl_j_l_clavicle.s" "ctrl_j_l_shoulder.is";
connectAttr "ctrl_j_l_elbow_parentConstraint1.ctx" "ctrl_j_l_elbow.tx";
connectAttr "ctrl_j_l_elbow_parentConstraint1.cty" "ctrl_j_l_elbow.ty";
connectAttr "ctrl_j_l_elbow_parentConstraint1.ctz" "ctrl_j_l_elbow.tz";
connectAttr "ctrl_j_l_elbow_parentConstraint1.crx" "ctrl_j_l_elbow.rx";
connectAttr "ctrl_j_l_elbow_parentConstraint1.cry" "ctrl_j_l_elbow.ry";
connectAttr "ctrl_j_l_elbow_parentConstraint1.crz" "ctrl_j_l_elbow.rz";
connectAttr "ctrl_j_l_shoulder.s" "ctrl_j_l_elbow.is";
connectAttr "ctrl_j_l_wrist_parentConstraint1.ctx" "ctrl_j_l_wrist.tx";
connectAttr "ctrl_j_l_wrist_parentConstraint1.cty" "ctrl_j_l_wrist.ty";
connectAttr "ctrl_j_l_wrist_parentConstraint1.ctz" "ctrl_j_l_wrist.tz";
connectAttr "ctrl_j_l_wrist_parentConstraint1.crx" "ctrl_j_l_wrist.rx";
connectAttr "ctrl_j_l_wrist_parentConstraint1.cry" "ctrl_j_l_wrist.ry";
connectAttr "ctrl_j_l_wrist_parentConstraint1.crz" "ctrl_j_l_wrist.rz";
connectAttr "ctrl_j_l_elbow.s" "ctrl_j_l_wrist.is";
connectAttr "ctrl_j_l_wrist.ro" "ctrl_j_l_wrist_parentConstraint1.cro";
connectAttr "ctrl_j_l_wrist.pim" "ctrl_j_l_wrist_parentConstraint1.cpim";
connectAttr "ctrl_j_l_wrist.rp" "ctrl_j_l_wrist_parentConstraint1.crp";
connectAttr "ctrl_j_l_wrist.rpt" "ctrl_j_l_wrist_parentConstraint1.crt";
connectAttr "ctrl_j_l_wrist.jo" "ctrl_j_l_wrist_parentConstraint1.cjo";
connectAttr "ctrl_l_wrist.t" "ctrl_j_l_wrist_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_wrist.rp" "ctrl_j_l_wrist_parentConstraint1.tg[0].trp";
connectAttr "ctrl_l_wrist.rpt" "ctrl_j_l_wrist_parentConstraint1.tg[0].trt";
connectAttr "ctrl_l_wrist.r" "ctrl_j_l_wrist_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_wrist.ro" "ctrl_j_l_wrist_parentConstraint1.tg[0].tro";
connectAttr "ctrl_l_wrist.s" "ctrl_j_l_wrist_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_wrist.pm" "ctrl_j_l_wrist_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_wrist_parentConstraint1.w0" "ctrl_j_l_wrist_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_elbow.ro" "ctrl_j_l_elbow_parentConstraint1.cro";
connectAttr "ctrl_j_l_elbow.pim" "ctrl_j_l_elbow_parentConstraint1.cpim";
connectAttr "ctrl_j_l_elbow.rp" "ctrl_j_l_elbow_parentConstraint1.crp";
connectAttr "ctrl_j_l_elbow.rpt" "ctrl_j_l_elbow_parentConstraint1.crt";
connectAttr "ctrl_j_l_elbow.jo" "ctrl_j_l_elbow_parentConstraint1.cjo";
connectAttr "ctrl_l_elbow.t" "ctrl_j_l_elbow_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_elbow.rp" "ctrl_j_l_elbow_parentConstraint1.tg[0].trp";
connectAttr "ctrl_l_elbow.rpt" "ctrl_j_l_elbow_parentConstraint1.tg[0].trt";
connectAttr "ctrl_l_elbow.r" "ctrl_j_l_elbow_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_elbow.ro" "ctrl_j_l_elbow_parentConstraint1.tg[0].tro";
connectAttr "ctrl_l_elbow.s" "ctrl_j_l_elbow_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_elbow.pm" "ctrl_j_l_elbow_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_elbow_parentConstraint1.w0" "ctrl_j_l_elbow_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_shoulder.ro" "ctrl_j_l_shoulder_parentConstraint1.cro";
connectAttr "ctrl_j_l_shoulder.pim" "ctrl_j_l_shoulder_parentConstraint1.cpim";
connectAttr "ctrl_j_l_shoulder.rp" "ctrl_j_l_shoulder_parentConstraint1.crp";
connectAttr "ctrl_j_l_shoulder.rpt" "ctrl_j_l_shoulder_parentConstraint1.crt";
connectAttr "ctrl_j_l_shoulder.jo" "ctrl_j_l_shoulder_parentConstraint1.cjo";
connectAttr "ctrl_l_shoulder.t" "ctrl_j_l_shoulder_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_shoulder.rp" "ctrl_j_l_shoulder_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_l_shoulder.rpt" "ctrl_j_l_shoulder_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_l_shoulder.r" "ctrl_j_l_shoulder_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_shoulder.ro" "ctrl_j_l_shoulder_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_l_shoulder.s" "ctrl_j_l_shoulder_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_shoulder.pm" "ctrl_j_l_shoulder_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_l_shoulder_parentConstraint1.w0" "ctrl_j_l_shoulder_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_clavicle.ro" "ctrl_j_l_clavicle_parentConstraint1.cro";
connectAttr "ctrl_j_l_clavicle.pim" "ctrl_j_l_clavicle_parentConstraint1.cpim";
connectAttr "ctrl_j_l_clavicle.rp" "ctrl_j_l_clavicle_parentConstraint1.crp";
connectAttr "ctrl_j_l_clavicle.rpt" "ctrl_j_l_clavicle_parentConstraint1.crt";
connectAttr "ctrl_j_l_clavicle.jo" "ctrl_j_l_clavicle_parentConstraint1.cjo";
connectAttr "ctrl_l_clavicle.t" "ctrl_j_l_clavicle_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_clavicle.rp" "ctrl_j_l_clavicle_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_l_clavicle.rpt" "ctrl_j_l_clavicle_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_l_clavicle.r" "ctrl_j_l_clavicle_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_clavicle.ro" "ctrl_j_l_clavicle_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_l_clavicle.s" "ctrl_j_l_clavicle_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_clavicle.pm" "ctrl_j_l_clavicle_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_l_clavicle_parentConstraint1.w0" "ctrl_j_l_clavicle_parentConstraint1.tg[0].tw"
		;
connectAttr "tail.di" "ctrl_tail_01.do";
connectAttr "tail.di" "ctrl_tail_02.do";
connectAttr "tail.di" "ctrl_tail_03.do";
connectAttr "tail.di" "ctrl_tail_04.do";
connectAttr "tail.di" "ctrl_tail_05.do";
connectAttr "groupId60.id" "ctrl_pelvis_lowShape.iog.og[0].gid";
connectAttr "surfaceShader1SG.mwc" "ctrl_pelvis_lowShape.iog.og[0].gco";
connectAttr "ik_j_pelvis_parentConstraint1.crx" "ik_j_pelvis.rx";
connectAttr "ik_j_pelvis_parentConstraint1.cry" "ik_j_pelvis.ry";
connectAttr "ik_j_pelvis_parentConstraint1.crz" "ik_j_pelvis.rz";
connectAttr "ik_j_pelvis_parentConstraint1.ctx" "ik_j_pelvis.tx";
connectAttr "ik_j_pelvis_parentConstraint1.cty" "ik_j_pelvis.ty";
connectAttr "ik_j_pelvis_parentConstraint1.ctz" "ik_j_pelvis.tz";
connectAttr "ik_j_pelvis.ro" "ik_j_pelvis_parentConstraint1.cro";
connectAttr "ik_j_pelvis.pim" "ik_j_pelvis_parentConstraint1.cpim";
connectAttr "ik_j_pelvis.rp" "ik_j_pelvis_parentConstraint1.crp";
connectAttr "ik_j_pelvis.rpt" "ik_j_pelvis_parentConstraint1.crt";
connectAttr "ik_j_pelvis.jo" "ik_j_pelvis_parentConstraint1.cjo";
connectAttr "ctrl_pelvis.t" "ik_j_pelvis_parentConstraint1.tg[0].tt";
connectAttr "ctrl_pelvis.rp" "ik_j_pelvis_parentConstraint1.tg[0].trp";
connectAttr "ctrl_pelvis.rpt" "ik_j_pelvis_parentConstraint1.tg[0].trt";
connectAttr "ctrl_pelvis.r" "ik_j_pelvis_parentConstraint1.tg[0].tr";
connectAttr "ctrl_pelvis.ro" "ik_j_pelvis_parentConstraint1.tg[0].tro";
connectAttr "ctrl_pelvis.s" "ik_j_pelvis_parentConstraint1.tg[0].ts";
connectAttr "ctrl_pelvis.pm" "ik_j_pelvis_parentConstraint1.tg[0].tpm";
connectAttr "ik_j_pelvis_parentConstraint1.w0" "ik_j_pelvis_parentConstraint1.tg[0].tw"
		;
connectAttr "ik_j_spine_03_parentConstraint1.ctx" "ik_j_spine_03.tx";
connectAttr "ik_j_spine_03_parentConstraint1.cty" "ik_j_spine_03.ty";
connectAttr "ik_j_spine_03_parentConstraint1.ctz" "ik_j_spine_03.tz";
connectAttr "ik_j_spine_03_parentConstraint1.crx" "ik_j_spine_03.rx";
connectAttr "ik_j_spine_03_parentConstraint1.cry" "ik_j_spine_03.ry";
connectAttr "ik_j_spine_03_parentConstraint1.crz" "ik_j_spine_03.rz";
connectAttr "ik_j_spine_03.ro" "ik_j_spine_03_parentConstraint1.cro";
connectAttr "ik_j_spine_03.pim" "ik_j_spine_03_parentConstraint1.cpim";
connectAttr "ik_j_spine_03.rp" "ik_j_spine_03_parentConstraint1.crp";
connectAttr "ik_j_spine_03.rpt" "ik_j_spine_03_parentConstraint1.crt";
connectAttr "ik_j_spine_03.jo" "ik_j_spine_03_parentConstraint1.cjo";
connectAttr "ctrl_spine_03.t" "ik_j_spine_03_parentConstraint1.tg[0].tt";
connectAttr "ctrl_spine_03.rp" "ik_j_spine_03_parentConstraint1.tg[0].trp";
connectAttr "ctrl_spine_03.rpt" "ik_j_spine_03_parentConstraint1.tg[0].trt";
connectAttr "ctrl_spine_03.r" "ik_j_spine_03_parentConstraint1.tg[0].tr";
connectAttr "ctrl_spine_03.ro" "ik_j_spine_03_parentConstraint1.tg[0].tro";
connectAttr "ctrl_spine_03.s" "ik_j_spine_03_parentConstraint1.tg[0].ts";
connectAttr "ctrl_spine_03.pm" "ik_j_spine_03_parentConstraint1.tg[0].tpm";
connectAttr "ik_j_spine_03_parentConstraint1.w0" "ik_j_spine_03_parentConstraint1.tg[0].tw"
		;
connectAttr "skinCluster1.og[0]" "crv_spineShape.cr";
connectAttr "tweak1.pl[0].cp[0]" "crv_spineShape.twl";
connectAttr "skinCluster1GroupId.id" "crv_spineShape.iog.og[0].gid";
connectAttr "skinCluster1Set.mwc" "crv_spineShape.iog.og[0].gco";
connectAttr "groupId55.id" "crv_spineShape.iog.og[1].gid";
connectAttr "tweakSet1.mwc" "crv_spineShape.iog.og[1].gco";
connectAttr "ctrl_j_pelvis.msg" "ik_spine_hndl.hsj";
connectAttr "effector1.hp" "ik_spine_hndl.hee";
connectAttr "ikSplineSolver.msg" "ik_spine_hndl.hsv";
connectAttr "crv_spineShape.ws" "ik_spine_hndl.ic";
connectAttr "ctrl_pelvis.wm" "ik_spine_hndl.dwum";
connectAttr "ctrl_spine_03.wm" "ik_spine_hndl.dwue";
connectAttr "ctrl_j_pelvis_orientConstraint1.crx" "ctrl_j_pelvis.rx";
connectAttr "ctrl_j_pelvis_orientConstraint1.cry" "ctrl_j_pelvis.ry";
connectAttr "ctrl_j_pelvis_orientConstraint1.crz" "ctrl_j_pelvis.rz";
connectAttr "spine_01_plus.o1" "ctrl_j_spine_01.tx";
connectAttr "ctrl_j_pelvis.s" "ctrl_j_spine_01.is";
connectAttr "spine_02_plus.o1" "ctrl_j_spine_02.tx";
connectAttr "ctrl_j_spine_01.s" "ctrl_j_spine_02.is";
connectAttr "spine_03_plus.o1" "ctrl_j_spine_03.tx";
connectAttr "ctrl_j_spine_03_orientConstraint1.crx" "ctrl_j_spine_03.rx";
connectAttr "ctrl_j_spine_03_orientConstraint1.cry" "ctrl_j_spine_03.ry";
connectAttr "ctrl_j_spine_03_orientConstraint1.crz" "ctrl_j_spine_03.rz";
connectAttr "ctrl_j_spine_02.s" "ctrl_j_spine_03.is";
connectAttr "ctrl_j_spine_03.ro" "ctrl_j_spine_03_orientConstraint1.cro";
connectAttr "ctrl_j_spine_03.pim" "ctrl_j_spine_03_orientConstraint1.cpim";
connectAttr "ctrl_j_spine_03.jo" "ctrl_j_spine_03_orientConstraint1.cjo";
connectAttr "ctrl_j_spine_03.is" "ctrl_j_spine_03_orientConstraint1.is";
connectAttr "ctrl_spine_03.r" "ctrl_j_spine_03_orientConstraint1.tg[0].tr";
connectAttr "ctrl_spine_03.ro" "ctrl_j_spine_03_orientConstraint1.tg[0].tro";
connectAttr "ctrl_spine_03.pm" "ctrl_j_spine_03_orientConstraint1.tg[0].tpm";
connectAttr "ctrl_j_spine_03_orientConstraint1.w0" "ctrl_j_spine_03_orientConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_neck_parentConstraint1.ctx" "ctrl_j_neck.tx";
connectAttr "ctrl_j_neck_parentConstraint1.cty" "ctrl_j_neck.ty";
connectAttr "ctrl_j_neck_parentConstraint1.ctz" "ctrl_j_neck.tz";
connectAttr "ctrl_j_neck_parentConstraint1.crx" "ctrl_j_neck.rx";
connectAttr "ctrl_j_neck_parentConstraint1.cry" "ctrl_j_neck.ry";
connectAttr "ctrl_j_neck_parentConstraint1.crz" "ctrl_j_neck.rz";
connectAttr "ctrl_j_spine_03.s" "ctrl_j_neck.is";
connectAttr "ctrl_j_head_parentConstraint1.ctx" "ctrl_j_head.tx";
connectAttr "ctrl_j_head_parentConstraint1.cty" "ctrl_j_head.ty";
connectAttr "ctrl_j_head_parentConstraint1.ctz" "ctrl_j_head.tz";
connectAttr "ctrl_j_head_parentConstraint1.crx" "ctrl_j_head.rx";
connectAttr "ctrl_j_head_parentConstraint1.cry" "ctrl_j_head.ry";
connectAttr "ctrl_j_head_parentConstraint1.crz" "ctrl_j_head.rz";
connectAttr "ctrl_j_neck.s" "ctrl_j_head.is";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.ctx" "ctrl_j_r_ear_01.tx";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.cty" "ctrl_j_r_ear_01.ty";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.ctz" "ctrl_j_r_ear_01.tz";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.crx" "ctrl_j_r_ear_01.rx";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.cry" "ctrl_j_r_ear_01.ry";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.crz" "ctrl_j_r_ear_01.rz";
connectAttr "ctrl_j_head.s" "ctrl_j_r_ear_01.is";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.ctx" "ctrl_j_r_ear_02.tx";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.cty" "ctrl_j_r_ear_02.ty";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.ctz" "ctrl_j_r_ear_02.tz";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.crx" "ctrl_j_r_ear_02.rx";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.cry" "ctrl_j_r_ear_02.ry";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.crz" "ctrl_j_r_ear_02.rz";
connectAttr "ctrl_j_r_ear_01.s" "ctrl_j_r_ear_02.is";
connectAttr "ctrl_j_r_ear_02.ro" "ctrl_j_r_ear_02_parentConstraint1.cro";
connectAttr "ctrl_j_r_ear_02.pim" "ctrl_j_r_ear_02_parentConstraint1.cpim";
connectAttr "ctrl_j_r_ear_02.rp" "ctrl_j_r_ear_02_parentConstraint1.crp";
connectAttr "ctrl_j_r_ear_02.rpt" "ctrl_j_r_ear_02_parentConstraint1.crt";
connectAttr "ctrl_j_r_ear_02.jo" "ctrl_j_r_ear_02_parentConstraint1.cjo";
connectAttr "ctrl_r_ear_02.t" "ctrl_j_r_ear_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_ear_02.rp" "ctrl_j_r_ear_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_r_ear_02.rpt" "ctrl_j_r_ear_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_r_ear_02.r" "ctrl_j_r_ear_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_ear_02.ro" "ctrl_j_r_ear_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_r_ear_02.s" "ctrl_j_r_ear_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_ear_02.pm" "ctrl_j_r_ear_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_ear_02_parentConstraint1.w0" "ctrl_j_r_ear_02_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_ear_01.ro" "ctrl_j_r_ear_01_parentConstraint1.cro";
connectAttr "ctrl_j_r_ear_01.pim" "ctrl_j_r_ear_01_parentConstraint1.cpim";
connectAttr "ctrl_j_r_ear_01.rp" "ctrl_j_r_ear_01_parentConstraint1.crp";
connectAttr "ctrl_j_r_ear_01.rpt" "ctrl_j_r_ear_01_parentConstraint1.crt";
connectAttr "ctrl_j_r_ear_01.jo" "ctrl_j_r_ear_01_parentConstraint1.cjo";
connectAttr "ctrl_r_ear_01.t" "ctrl_j_r_ear_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_r_ear_01.rp" "ctrl_j_r_ear_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_r_ear_01.rpt" "ctrl_j_r_ear_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_r_ear_01.r" "ctrl_j_r_ear_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_r_ear_01.ro" "ctrl_j_r_ear_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_r_ear_01.s" "ctrl_j_r_ear_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_r_ear_01.pm" "ctrl_j_r_ear_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_r_ear_01_parentConstraint1.w0" "ctrl_j_r_ear_01_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_ear_01_parentConstraint1.ctx" "ctrl_j_l_ear_01.tx";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.cty" "ctrl_j_l_ear_01.ty";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.ctz" "ctrl_j_l_ear_01.tz";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.crx" "ctrl_j_l_ear_01.rx";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.cry" "ctrl_j_l_ear_01.ry";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.crz" "ctrl_j_l_ear_01.rz";
connectAttr "ctrl_j_head.s" "ctrl_j_l_ear_01.is";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.ctx" "ctrl_j_l_ear_02.tx";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.cty" "ctrl_j_l_ear_02.ty";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.ctz" "ctrl_j_l_ear_02.tz";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.crx" "ctrl_j_l_ear_02.rx";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.cry" "ctrl_j_l_ear_02.ry";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.crz" "ctrl_j_l_ear_02.rz";
connectAttr "ctrl_j_l_ear_01.s" "ctrl_j_l_ear_02.is";
connectAttr "ctrl_j_l_ear_02.ro" "ctrl_j_l_ear_02_parentConstraint1.cro";
connectAttr "ctrl_j_l_ear_02.pim" "ctrl_j_l_ear_02_parentConstraint1.cpim";
connectAttr "ctrl_j_l_ear_02.rp" "ctrl_j_l_ear_02_parentConstraint1.crp";
connectAttr "ctrl_j_l_ear_02.rpt" "ctrl_j_l_ear_02_parentConstraint1.crt";
connectAttr "ctrl_j_l_ear_02.jo" "ctrl_j_l_ear_02_parentConstraint1.cjo";
connectAttr "ctrl_l_ear_02.t" "ctrl_j_l_ear_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_ear_02.rp" "ctrl_j_l_ear_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_l_ear_02.rpt" "ctrl_j_l_ear_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_l_ear_02.r" "ctrl_j_l_ear_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_ear_02.ro" "ctrl_j_l_ear_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_l_ear_02.s" "ctrl_j_l_ear_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_ear_02.pm" "ctrl_j_l_ear_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_ear_02_parentConstraint1.w0" "ctrl_j_l_ear_02_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_ear_01.ro" "ctrl_j_l_ear_01_parentConstraint1.cro";
connectAttr "ctrl_j_l_ear_01.pim" "ctrl_j_l_ear_01_parentConstraint1.cpim";
connectAttr "ctrl_j_l_ear_01.rp" "ctrl_j_l_ear_01_parentConstraint1.crp";
connectAttr "ctrl_j_l_ear_01.rpt" "ctrl_j_l_ear_01_parentConstraint1.crt";
connectAttr "ctrl_j_l_ear_01.jo" "ctrl_j_l_ear_01_parentConstraint1.cjo";
connectAttr "ctrl_l_ear_01.t" "ctrl_j_l_ear_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_l_ear_01.rp" "ctrl_j_l_ear_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_l_ear_01.rpt" "ctrl_j_l_ear_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_l_ear_01.r" "ctrl_j_l_ear_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_l_ear_01.ro" "ctrl_j_l_ear_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_l_ear_01.s" "ctrl_j_l_ear_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_l_ear_01.pm" "ctrl_j_l_ear_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_l_ear_01_parentConstraint1.w0" "ctrl_j_l_ear_01_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_head.ro" "ctrl_j_head_parentConstraint1.cro";
connectAttr "ctrl_j_head.pim" "ctrl_j_head_parentConstraint1.cpim";
connectAttr "ctrl_j_head.rp" "ctrl_j_head_parentConstraint1.crp";
connectAttr "ctrl_j_head.rpt" "ctrl_j_head_parentConstraint1.crt";
connectAttr "ctrl_j_head.jo" "ctrl_j_head_parentConstraint1.cjo";
connectAttr "ctrl_head.t" "ctrl_j_head_parentConstraint1.tg[0].tt";
connectAttr "ctrl_head.rp" "ctrl_j_head_parentConstraint1.tg[0].trp";
connectAttr "ctrl_head.rpt" "ctrl_j_head_parentConstraint1.tg[0].trt";
connectAttr "ctrl_head.r" "ctrl_j_head_parentConstraint1.tg[0].tr";
connectAttr "ctrl_head.ro" "ctrl_j_head_parentConstraint1.tg[0].tro";
connectAttr "ctrl_head.s" "ctrl_j_head_parentConstraint1.tg[0].ts";
connectAttr "ctrl_head.pm" "ctrl_j_head_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_head_parentConstraint1.w0" "ctrl_j_head_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_neck.ro" "ctrl_j_neck_parentConstraint1.cro";
connectAttr "ctrl_j_neck.pim" "ctrl_j_neck_parentConstraint1.cpim";
connectAttr "ctrl_j_neck.rp" "ctrl_j_neck_parentConstraint1.crp";
connectAttr "ctrl_j_neck.rpt" "ctrl_j_neck_parentConstraint1.crt";
connectAttr "ctrl_j_neck.jo" "ctrl_j_neck_parentConstraint1.cjo";
connectAttr "ctrl_neck.t" "ctrl_j_neck_parentConstraint1.tg[0].tt";
connectAttr "ctrl_neck.rp" "ctrl_j_neck_parentConstraint1.tg[0].trp";
connectAttr "ctrl_neck.rpt" "ctrl_j_neck_parentConstraint1.tg[0].trt";
connectAttr "ctrl_neck.r" "ctrl_j_neck_parentConstraint1.tg[0].tr";
connectAttr "ctrl_neck.ro" "ctrl_j_neck_parentConstraint1.tg[0].tro";
connectAttr "ctrl_neck.s" "ctrl_j_neck_parentConstraint1.tg[0].ts";
connectAttr "ctrl_neck.pm" "ctrl_j_neck_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_neck_parentConstraint1.w0" "ctrl_j_neck_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_spine_03.tx" "effector1.tx";
connectAttr "ctrl_j_spine_03.ty" "effector1.ty";
connectAttr "ctrl_j_spine_03.tz" "effector1.tz";
connectAttr "ctrl_j_tail_01_parentConstraint1.ctx" "ctrl_j_tail_01.tx";
connectAttr "ctrl_j_tail_01_parentConstraint1.cty" "ctrl_j_tail_01.ty";
connectAttr "ctrl_j_tail_01_parentConstraint1.ctz" "ctrl_j_tail_01.tz";
connectAttr "ctrl_j_tail_01_parentConstraint1.crx" "ctrl_j_tail_01.rx";
connectAttr "ctrl_j_tail_01_parentConstraint1.cry" "ctrl_j_tail_01.ry";
connectAttr "ctrl_j_tail_01_parentConstraint1.crz" "ctrl_j_tail_01.rz";
connectAttr "ctrl_j_spine_01.s" "ctrl_j_tail_01.is";
connectAttr "ctrl_j_tail_02_parentConstraint1.ctx" "ctrl_j_tail_02.tx";
connectAttr "ctrl_j_tail_02_parentConstraint1.cty" "ctrl_j_tail_02.ty";
connectAttr "ctrl_j_tail_02_parentConstraint1.ctz" "ctrl_j_tail_02.tz";
connectAttr "ctrl_j_tail_02_parentConstraint1.crx" "ctrl_j_tail_02.rx";
connectAttr "ctrl_j_tail_02_parentConstraint1.cry" "ctrl_j_tail_02.ry";
connectAttr "ctrl_j_tail_02_parentConstraint1.crz" "ctrl_j_tail_02.rz";
connectAttr "ctrl_j_tail_01.s" "ctrl_j_tail_02.is";
connectAttr "ctrl_j_tail_03_parentConstraint1.ctx" "ctrl_j_tail_03.tx";
connectAttr "ctrl_j_tail_03_parentConstraint1.cty" "ctrl_j_tail_03.ty";
connectAttr "ctrl_j_tail_03_parentConstraint1.ctz" "ctrl_j_tail_03.tz";
connectAttr "ctrl_j_tail_03_parentConstraint1.crx" "ctrl_j_tail_03.rx";
connectAttr "ctrl_j_tail_03_parentConstraint1.cry" "ctrl_j_tail_03.ry";
connectAttr "ctrl_j_tail_03_parentConstraint1.crz" "ctrl_j_tail_03.rz";
connectAttr "ctrl_j_tail_02.s" "ctrl_j_tail_03.is";
connectAttr "ctrl_j_tail_04_parentConstraint1.ctx" "ctrl_j_tail_04.tx";
connectAttr "ctrl_j_tail_04_parentConstraint1.cty" "ctrl_j_tail_04.ty";
connectAttr "ctrl_j_tail_04_parentConstraint1.ctz" "ctrl_j_tail_04.tz";
connectAttr "ctrl_j_tail_04_parentConstraint1.crx" "ctrl_j_tail_04.rx";
connectAttr "ctrl_j_tail_04_parentConstraint1.cry" "ctrl_j_tail_04.ry";
connectAttr "ctrl_j_tail_04_parentConstraint1.crz" "ctrl_j_tail_04.rz";
connectAttr "ctrl_j_tail_03.s" "ctrl_j_tail_04.is";
connectAttr "ctrl_j_tail_05_parentConstraint1.ctx" "ctrl_j_tail_05.tx";
connectAttr "ctrl_j_tail_05_parentConstraint1.cty" "ctrl_j_tail_05.ty";
connectAttr "ctrl_j_tail_05_parentConstraint1.ctz" "ctrl_j_tail_05.tz";
connectAttr "ctrl_j_tail_05_parentConstraint1.crx" "ctrl_j_tail_05.rx";
connectAttr "ctrl_j_tail_05_parentConstraint1.cry" "ctrl_j_tail_05.ry";
connectAttr "ctrl_j_tail_05_parentConstraint1.crz" "ctrl_j_tail_05.rz";
connectAttr "ctrl_j_tail_04.s" "ctrl_j_tail_05.is";
connectAttr "ctrl_j_tail_05.ro" "ctrl_j_tail_05_parentConstraint1.cro";
connectAttr "ctrl_j_tail_05.pim" "ctrl_j_tail_05_parentConstraint1.cpim";
connectAttr "ctrl_j_tail_05.rp" "ctrl_j_tail_05_parentConstraint1.crp";
connectAttr "ctrl_j_tail_05.rpt" "ctrl_j_tail_05_parentConstraint1.crt";
connectAttr "ctrl_j_tail_05.jo" "ctrl_j_tail_05_parentConstraint1.cjo";
connectAttr "ctrl_tail_05.t" "ctrl_j_tail_05_parentConstraint1.tg[0].tt";
connectAttr "ctrl_tail_05.rp" "ctrl_j_tail_05_parentConstraint1.tg[0].trp";
connectAttr "ctrl_tail_05.rpt" "ctrl_j_tail_05_parentConstraint1.tg[0].trt";
connectAttr "ctrl_tail_05.r" "ctrl_j_tail_05_parentConstraint1.tg[0].tr";
connectAttr "ctrl_tail_05.ro" "ctrl_j_tail_05_parentConstraint1.tg[0].tro";
connectAttr "ctrl_tail_05.s" "ctrl_j_tail_05_parentConstraint1.tg[0].ts";
connectAttr "ctrl_tail_05.pm" "ctrl_j_tail_05_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_05_parentConstraint1.w0" "ctrl_j_tail_05_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_tail_04.ro" "ctrl_j_tail_04_parentConstraint1.cro";
connectAttr "ctrl_j_tail_04.pim" "ctrl_j_tail_04_parentConstraint1.cpim";
connectAttr "ctrl_j_tail_04.rp" "ctrl_j_tail_04_parentConstraint1.crp";
connectAttr "ctrl_j_tail_04.rpt" "ctrl_j_tail_04_parentConstraint1.crt";
connectAttr "ctrl_j_tail_04.jo" "ctrl_j_tail_04_parentConstraint1.cjo";
connectAttr "ctrl_tail_04.t" "ctrl_j_tail_04_parentConstraint1.tg[0].tt";
connectAttr "ctrl_tail_04.rp" "ctrl_j_tail_04_parentConstraint1.tg[0].trp";
connectAttr "ctrl_tail_04.rpt" "ctrl_j_tail_04_parentConstraint1.tg[0].trt";
connectAttr "ctrl_tail_04.r" "ctrl_j_tail_04_parentConstraint1.tg[0].tr";
connectAttr "ctrl_tail_04.ro" "ctrl_j_tail_04_parentConstraint1.tg[0].tro";
connectAttr "ctrl_tail_04.s" "ctrl_j_tail_04_parentConstraint1.tg[0].ts";
connectAttr "ctrl_tail_04.pm" "ctrl_j_tail_04_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_04_parentConstraint1.w0" "ctrl_j_tail_04_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_tail_03.ro" "ctrl_j_tail_03_parentConstraint1.cro";
connectAttr "ctrl_j_tail_03.pim" "ctrl_j_tail_03_parentConstraint1.cpim";
connectAttr "ctrl_j_tail_03.rp" "ctrl_j_tail_03_parentConstraint1.crp";
connectAttr "ctrl_j_tail_03.rpt" "ctrl_j_tail_03_parentConstraint1.crt";
connectAttr "ctrl_j_tail_03.jo" "ctrl_j_tail_03_parentConstraint1.cjo";
connectAttr "ctrl_tail_03.t" "ctrl_j_tail_03_parentConstraint1.tg[0].tt";
connectAttr "ctrl_tail_03.rp" "ctrl_j_tail_03_parentConstraint1.tg[0].trp";
connectAttr "ctrl_tail_03.rpt" "ctrl_j_tail_03_parentConstraint1.tg[0].trt";
connectAttr "ctrl_tail_03.r" "ctrl_j_tail_03_parentConstraint1.tg[0].tr";
connectAttr "ctrl_tail_03.ro" "ctrl_j_tail_03_parentConstraint1.tg[0].tro";
connectAttr "ctrl_tail_03.s" "ctrl_j_tail_03_parentConstraint1.tg[0].ts";
connectAttr "ctrl_tail_03.pm" "ctrl_j_tail_03_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_03_parentConstraint1.w0" "ctrl_j_tail_03_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_tail_02.ro" "ctrl_j_tail_02_parentConstraint1.cro";
connectAttr "ctrl_j_tail_02.pim" "ctrl_j_tail_02_parentConstraint1.cpim";
connectAttr "ctrl_j_tail_02.rp" "ctrl_j_tail_02_parentConstraint1.crp";
connectAttr "ctrl_j_tail_02.rpt" "ctrl_j_tail_02_parentConstraint1.crt";
connectAttr "ctrl_j_tail_02.jo" "ctrl_j_tail_02_parentConstraint1.cjo";
connectAttr "ctrl_tail_02.t" "ctrl_j_tail_02_parentConstraint1.tg[0].tt";
connectAttr "ctrl_tail_02.rp" "ctrl_j_tail_02_parentConstraint1.tg[0].trp";
connectAttr "ctrl_tail_02.rpt" "ctrl_j_tail_02_parentConstraint1.tg[0].trt";
connectAttr "ctrl_tail_02.r" "ctrl_j_tail_02_parentConstraint1.tg[0].tr";
connectAttr "ctrl_tail_02.ro" "ctrl_j_tail_02_parentConstraint1.tg[0].tro";
connectAttr "ctrl_tail_02.s" "ctrl_j_tail_02_parentConstraint1.tg[0].ts";
connectAttr "ctrl_tail_02.pm" "ctrl_j_tail_02_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_02_parentConstraint1.w0" "ctrl_j_tail_02_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_tail_01.ro" "ctrl_j_tail_01_parentConstraint1.cro";
connectAttr "ctrl_j_tail_01.pim" "ctrl_j_tail_01_parentConstraint1.cpim";
connectAttr "ctrl_j_tail_01.rp" "ctrl_j_tail_01_parentConstraint1.crp";
connectAttr "ctrl_j_tail_01.rpt" "ctrl_j_tail_01_parentConstraint1.crt";
connectAttr "ctrl_j_tail_01.jo" "ctrl_j_tail_01_parentConstraint1.cjo";
connectAttr "ctrl_tail_01.t" "ctrl_j_tail_01_parentConstraint1.tg[0].tt";
connectAttr "ctrl_tail_01.rp" "ctrl_j_tail_01_parentConstraint1.tg[0].trp";
connectAttr "ctrl_tail_01.rpt" "ctrl_j_tail_01_parentConstraint1.tg[0].trt";
connectAttr "ctrl_tail_01.r" "ctrl_j_tail_01_parentConstraint1.tg[0].tr";
connectAttr "ctrl_tail_01.ro" "ctrl_j_tail_01_parentConstraint1.tg[0].tro";
connectAttr "ctrl_tail_01.s" "ctrl_j_tail_01_parentConstraint1.tg[0].ts";
connectAttr "ctrl_tail_01.pm" "ctrl_j_tail_01_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_tail_01_parentConstraint1.w0" "ctrl_j_tail_01_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_pelvis_low_parentConstraint1.ctx" "ctrl_j_pelvis_low.tx";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.cty" "ctrl_j_pelvis_low.ty";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.ctz" "ctrl_j_pelvis_low.tz";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.crx" "ctrl_j_pelvis_low.rx";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.cry" "ctrl_j_pelvis_low.ry";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.crz" "ctrl_j_pelvis_low.rz";
connectAttr "ctrl_j_pelvis.s" "ctrl_j_pelvis_low.is";
connectAttr "ctrl_j_pelvis_low.ro" "ctrl_j_pelvis_low_parentConstraint1.cro";
connectAttr "ctrl_j_pelvis_low.pim" "ctrl_j_pelvis_low_parentConstraint1.cpim";
connectAttr "ctrl_j_pelvis_low.rp" "ctrl_j_pelvis_low_parentConstraint1.crp";
connectAttr "ctrl_j_pelvis_low.rpt" "ctrl_j_pelvis_low_parentConstraint1.crt";
connectAttr "ctrl_j_pelvis_low.jo" "ctrl_j_pelvis_low_parentConstraint1.cjo";
connectAttr "ctrl_pelvis_low.t" "ctrl_j_pelvis_low_parentConstraint1.tg[0].tt";
connectAttr "ctrl_pelvis_low.rp" "ctrl_j_pelvis_low_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_pelvis_low.rpt" "ctrl_j_pelvis_low_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_pelvis_low.r" "ctrl_j_pelvis_low_parentConstraint1.tg[0].tr";
connectAttr "ctrl_pelvis_low.ro" "ctrl_j_pelvis_low_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_pelvis_low.s" "ctrl_j_pelvis_low_parentConstraint1.tg[0].ts";
connectAttr "ctrl_pelvis_low.pm" "ctrl_j_pelvis_low_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_pelvis_low_parentConstraint1.w0" "ctrl_j_pelvis_low_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_pelvis.ro" "ctrl_j_pelvis_orientConstraint1.cro";
connectAttr "ctrl_j_pelvis.pim" "ctrl_j_pelvis_orientConstraint1.cpim";
connectAttr "ctrl_j_pelvis.jo" "ctrl_j_pelvis_orientConstraint1.cjo";
connectAttr "ctrl_j_pelvis.is" "ctrl_j_pelvis_orientConstraint1.is";
connectAttr "ik_j_pelvis.r" "ctrl_j_pelvis_orientConstraint1.tg[0].tr";
connectAttr "ik_j_pelvis.ro" "ctrl_j_pelvis_orientConstraint1.tg[0].tro";
connectAttr "ik_j_pelvis.pm" "ctrl_j_pelvis_orientConstraint1.tg[0].tpm";
connectAttr "ik_j_pelvis.jo" "ctrl_j_pelvis_orientConstraint1.tg[0].tjo";
connectAttr "ctrl_j_pelvis_orientConstraint1.w0" "ctrl_j_pelvis_orientConstraint1.tg[0].tw"
		;
connectAttr "left.di" "ctrl_l_foot.do";
connectAttr "IK_ctrl_j_l_femur.msg" "ik_l_leg.hsj";
connectAttr "effector2.hp" "ik_l_leg.hee";
connectAttr "ikRPsolver.msg" "ik_l_leg.hsv";
connectAttr "ik_l_leg_poleVectorConstraint1.ctx" "ik_l_leg.pvx";
connectAttr "ik_l_leg_poleVectorConstraint1.cty" "ik_l_leg.pvy";
connectAttr "ik_l_leg_poleVectorConstraint1.ctz" "ik_l_leg.pvz";
connectAttr "IK_ctrl_j_l_foot.msg" "ik_l_foot.hsj";
connectAttr "effector5.hp" "ik_l_foot.hee";
connectAttr "ikRPsolver.msg" "ik_l_foot.hsv";
connectAttr "ik_l_leg.pim" "ik_l_leg_poleVectorConstraint1.cpim";
connectAttr "IK_ctrl_j_l_femur.pm" "ik_l_leg_poleVectorConstraint1.ps";
connectAttr "IK_ctrl_j_l_femur.t" "ik_l_leg_poleVectorConstraint1.crp";
connectAttr "ctrl_l_leg_PV.t" "ik_l_leg_poleVectorConstraint1.tg[0].tt";
connectAttr "ctrl_l_leg_PV.rp" "ik_l_leg_poleVectorConstraint1.tg[0].trp";
connectAttr "ctrl_l_leg_PV.rpt" "ik_l_leg_poleVectorConstraint1.tg[0].trt";
connectAttr "ctrl_l_leg_PV.pm" "ik_l_leg_poleVectorConstraint1.tg[0].tpm";
connectAttr "ik_l_leg_poleVectorConstraint1.w0" "ik_l_leg_poleVectorConstraint1.tg[0].tw"
		;
connectAttr "left.di" "ctrl_l_leg_PV.do";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.ctx" "IK_ctrl_j_l_femur.tx";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.cty" "IK_ctrl_j_l_femur.ty";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.ctz" "IK_ctrl_j_l_femur.tz";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.crx" "IK_ctrl_j_l_femur.rx";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.cry" "IK_ctrl_j_l_femur.ry";
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.crz" "IK_ctrl_j_l_femur.rz";
connectAttr "IK_ctrl_j_l_femur.s" "IK_ctrl_j_l_knee.is";
connectAttr "IK_ctrl_j_l_knee.s" "IK_ctrl_j_l_heel.is";
connectAttr "IK_ctrl_j_l_heel.s" "IK_ctrl_j_l_foot.is";
connectAttr "IK_ctrl_j_l_foot.s" "IK_ctrl_j_l_toe.is";
connectAttr "IK_ctrl_j_l_toe.tx" "effector5.tx";
connectAttr "IK_ctrl_j_l_toe.ty" "effector5.ty";
connectAttr "IK_ctrl_j_l_toe.tz" "effector5.tz";
connectAttr "IK_ctrl_j_l_foot.tx" "effector2.tx";
connectAttr "IK_ctrl_j_l_foot.ty" "effector2.ty";
connectAttr "IK_ctrl_j_l_foot.tz" "effector2.tz";
connectAttr "IK_ctrl_j_l_femur.ro" "IK_ctrl_j_l_femur_parentConstraint1.cro";
connectAttr "IK_ctrl_j_l_femur.pim" "IK_ctrl_j_l_femur_parentConstraint1.cpim";
connectAttr "IK_ctrl_j_l_femur.rp" "IK_ctrl_j_l_femur_parentConstraint1.crp";
connectAttr "IK_ctrl_j_l_femur.rpt" "IK_ctrl_j_l_femur_parentConstraint1.crt";
connectAttr "IK_ctrl_j_l_femur.jo" "IK_ctrl_j_l_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_pelvis_low.t" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tt"
		;
connectAttr "ctrl_j_pelvis_low.rp" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_j_pelvis_low.rpt" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_j_pelvis_low.r" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tr"
		;
connectAttr "ctrl_j_pelvis_low.ro" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_j_pelvis_low.s" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].ts"
		;
connectAttr "ctrl_j_pelvis_low.pm" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_pelvis_low.jo" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tjo"
		;
connectAttr "ctrl_j_pelvis_low.ssc" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tsc"
		;
connectAttr "ctrl_j_pelvis_low.is" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tis"
		;
connectAttr "IK_ctrl_j_l_femur_parentConstraint1.w0" "IK_ctrl_j_l_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_femur_parentConstraint1.ctx" "ctrl_j_l_femur.tx";
connectAttr "ctrl_j_l_femur_parentConstraint1.cty" "ctrl_j_l_femur.ty";
connectAttr "ctrl_j_l_femur_parentConstraint1.ctz" "ctrl_j_l_femur.tz";
connectAttr "ctrl_j_l_femur_parentConstraint1.crx" "ctrl_j_l_femur.rx";
connectAttr "ctrl_j_l_femur_parentConstraint1.cry" "ctrl_j_l_femur.ry";
connectAttr "ctrl_j_l_femur_parentConstraint1.crz" "ctrl_j_l_femur.rz";
connectAttr "ctrl_j_l_knee_parentConstraint1.ctx" "ctrl_j_l_knee.tx";
connectAttr "ctrl_j_l_knee_parentConstraint1.cty" "ctrl_j_l_knee.ty";
connectAttr "ctrl_j_l_knee_parentConstraint1.ctz" "ctrl_j_l_knee.tz";
connectAttr "ctrl_j_l_knee_parentConstraint1.crx" "ctrl_j_l_knee.rx";
connectAttr "ctrl_j_l_knee_parentConstraint1.cry" "ctrl_j_l_knee.ry";
connectAttr "ctrl_j_l_knee_parentConstraint1.crz" "ctrl_j_l_knee.rz";
connectAttr "ctrl_j_l_femur.s" "ctrl_j_l_knee.is";
connectAttr "ctrl_j_l_heel_parentConstraint1.ctx" "ctrl_j_l_heel.tx";
connectAttr "ctrl_j_l_heel_parentConstraint1.cty" "ctrl_j_l_heel.ty";
connectAttr "ctrl_j_l_heel_parentConstraint1.ctz" "ctrl_j_l_heel.tz";
connectAttr "ctrl_j_l_heel_parentConstraint1.crx" "ctrl_j_l_heel.rx";
connectAttr "ctrl_j_l_heel_parentConstraint1.cry" "ctrl_j_l_heel.ry";
connectAttr "ctrl_j_l_heel_parentConstraint1.crz" "ctrl_j_l_heel.rz";
connectAttr "ctrl_j_l_knee.s" "ctrl_j_l_heel.is";
connectAttr "ctrl_j_l_foot_parentConstraint1.ctx" "ctrl_j_l_foot.tx";
connectAttr "ctrl_j_l_foot_parentConstraint1.cty" "ctrl_j_l_foot.ty";
connectAttr "ctrl_j_l_foot_parentConstraint1.ctz" "ctrl_j_l_foot.tz";
connectAttr "ctrl_j_l_foot_parentConstraint1.crx" "ctrl_j_l_foot.rx";
connectAttr "ctrl_j_l_foot_parentConstraint1.cry" "ctrl_j_l_foot.ry";
connectAttr "ctrl_j_l_foot_parentConstraint1.crz" "ctrl_j_l_foot.rz";
connectAttr "ctrl_j_l_heel.s" "ctrl_j_l_foot.is";
connectAttr "ctrl_j_l_toe_parentConstraint1.ctx" "ctrl_j_l_toe.tx";
connectAttr "ctrl_j_l_toe_parentConstraint1.cty" "ctrl_j_l_toe.ty";
connectAttr "ctrl_j_l_toe_parentConstraint1.ctz" "ctrl_j_l_toe.tz";
connectAttr "ctrl_j_l_toe_parentConstraint1.crx" "ctrl_j_l_toe.rx";
connectAttr "ctrl_j_l_toe_parentConstraint1.cry" "ctrl_j_l_toe.ry";
connectAttr "ctrl_j_l_toe_parentConstraint1.crz" "ctrl_j_l_toe.rz";
connectAttr "ctrl_j_l_foot.s" "ctrl_j_l_toe.is";
connectAttr "ctrl_j_l_toe.ro" "ctrl_j_l_toe_parentConstraint1.cro";
connectAttr "ctrl_j_l_toe.pim" "ctrl_j_l_toe_parentConstraint1.cpim";
connectAttr "ctrl_j_l_toe.rp" "ctrl_j_l_toe_parentConstraint1.crp";
connectAttr "ctrl_j_l_toe.rpt" "ctrl_j_l_toe_parentConstraint1.crt";
connectAttr "ctrl_j_l_toe.jo" "ctrl_j_l_toe_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_l_toe.t" "ctrl_j_l_toe_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_l_toe.rp" "ctrl_j_l_toe_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_l_toe.rpt" "ctrl_j_l_toe_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_l_toe.r" "ctrl_j_l_toe_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_l_toe.ro" "ctrl_j_l_toe_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_l_toe.s" "ctrl_j_l_toe_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_l_toe.pm" "ctrl_j_l_toe_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_l_toe.jo" "ctrl_j_l_toe_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_l_toe.ssc" "ctrl_j_l_toe_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_l_toe.is" "ctrl_j_l_toe_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_l_toe_parentConstraint1.w0" "ctrl_j_l_toe_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_foot.ro" "ctrl_j_l_foot_parentConstraint1.cro";
connectAttr "ctrl_j_l_foot.pim" "ctrl_j_l_foot_parentConstraint1.cpim";
connectAttr "ctrl_j_l_foot.rp" "ctrl_j_l_foot_parentConstraint1.crp";
connectAttr "ctrl_j_l_foot.rpt" "ctrl_j_l_foot_parentConstraint1.crt";
connectAttr "ctrl_j_l_foot.jo" "ctrl_j_l_foot_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_l_foot.t" "ctrl_j_l_foot_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_l_foot.rp" "ctrl_j_l_foot_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_l_foot.rpt" "ctrl_j_l_foot_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_l_foot.r" "ctrl_j_l_foot_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_l_foot.ro" "ctrl_j_l_foot_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_l_foot.s" "ctrl_j_l_foot_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_l_foot.pm" "ctrl_j_l_foot_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_l_foot.jo" "ctrl_j_l_foot_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_l_foot.ssc" "ctrl_j_l_foot_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_l_foot.is" "ctrl_j_l_foot_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_l_foot_parentConstraint1.w0" "ctrl_j_l_foot_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_heel.ro" "ctrl_j_l_heel_parentConstraint1.cro";
connectAttr "ctrl_j_l_heel.pim" "ctrl_j_l_heel_parentConstraint1.cpim";
connectAttr "ctrl_j_l_heel.rp" "ctrl_j_l_heel_parentConstraint1.crp";
connectAttr "ctrl_j_l_heel.rpt" "ctrl_j_l_heel_parentConstraint1.crt";
connectAttr "ctrl_j_l_heel.jo" "ctrl_j_l_heel_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_l_heel.t" "ctrl_j_l_heel_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_l_heel.rp" "ctrl_j_l_heel_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_l_heel.rpt" "ctrl_j_l_heel_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_l_heel.r" "ctrl_j_l_heel_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_l_heel.ro" "ctrl_j_l_heel_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_l_heel.s" "ctrl_j_l_heel_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_l_heel.pm" "ctrl_j_l_heel_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_l_heel.jo" "ctrl_j_l_heel_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_l_heel.ssc" "ctrl_j_l_heel_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_l_heel.is" "ctrl_j_l_heel_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_l_heel_parentConstraint1.w0" "ctrl_j_l_heel_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_knee.ro" "ctrl_j_l_knee_parentConstraint1.cro";
connectAttr "ctrl_j_l_knee.pim" "ctrl_j_l_knee_parentConstraint1.cpim";
connectAttr "ctrl_j_l_knee.rp" "ctrl_j_l_knee_parentConstraint1.crp";
connectAttr "ctrl_j_l_knee.rpt" "ctrl_j_l_knee_parentConstraint1.crt";
connectAttr "ctrl_j_l_knee.jo" "ctrl_j_l_knee_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_l_knee.t" "ctrl_j_l_knee_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_l_knee.rp" "ctrl_j_l_knee_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_l_knee.rpt" "ctrl_j_l_knee_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_l_knee.r" "ctrl_j_l_knee_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_l_knee.ro" "ctrl_j_l_knee_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_l_knee.s" "ctrl_j_l_knee_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_l_knee.pm" "ctrl_j_l_knee_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_l_knee.jo" "ctrl_j_l_knee_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_l_knee.ssc" "ctrl_j_l_knee_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_l_knee.is" "ctrl_j_l_knee_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_l_knee_parentConstraint1.w0" "ctrl_j_l_knee_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_l_femur.ro" "ctrl_j_l_femur_parentConstraint1.cro";
connectAttr "ctrl_j_l_femur.pim" "ctrl_j_l_femur_parentConstraint1.cpim";
connectAttr "ctrl_j_l_femur.rp" "ctrl_j_l_femur_parentConstraint1.crp";
connectAttr "ctrl_j_l_femur.rpt" "ctrl_j_l_femur_parentConstraint1.crt";
connectAttr "ctrl_j_l_femur.jo" "ctrl_j_l_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_pelvis_low.t" "ctrl_j_l_femur_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_pelvis_low.rp" "ctrl_j_l_femur_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_pelvis_low.rpt" "ctrl_j_l_femur_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_j_pelvis_low.r" "ctrl_j_l_femur_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_pelvis_low.ro" "ctrl_j_l_femur_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_pelvis_low.s" "ctrl_j_l_femur_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_pelvis_low.pm" "ctrl_j_l_femur_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_pelvis_low.jo" "ctrl_j_l_femur_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_pelvis_low.ssc" "ctrl_j_l_femur_parentConstraint1.tg[0].tsc"
		;
connectAttr "ctrl_j_pelvis_low.is" "ctrl_j_l_femur_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_l_femur_parentConstraint1.w0" "ctrl_j_l_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "IK_ctrl_j_l_femur.t" "ctrl_j_l_femur_parentConstraint1.tg[1].tt";
connectAttr "IK_ctrl_j_l_femur.rp" "ctrl_j_l_femur_parentConstraint1.tg[1].trp";
connectAttr "IK_ctrl_j_l_femur.rpt" "ctrl_j_l_femur_parentConstraint1.tg[1].trt"
		;
connectAttr "IK_ctrl_j_l_femur.r" "ctrl_j_l_femur_parentConstraint1.tg[1].tr";
connectAttr "IK_ctrl_j_l_femur.ro" "ctrl_j_l_femur_parentConstraint1.tg[1].tro";
connectAttr "IK_ctrl_j_l_femur.s" "ctrl_j_l_femur_parentConstraint1.tg[1].ts";
connectAttr "IK_ctrl_j_l_femur.pm" "ctrl_j_l_femur_parentConstraint1.tg[1].tpm";
connectAttr "IK_ctrl_j_l_femur.jo" "ctrl_j_l_femur_parentConstraint1.tg[1].tjo";
connectAttr "IK_ctrl_j_l_femur.ssc" "ctrl_j_l_femur_parentConstraint1.tg[1].tsc"
		;
connectAttr "IK_ctrl_j_l_femur.is" "ctrl_j_l_femur_parentConstraint1.tg[1].tis";
connectAttr "ctrl_j_l_femur_parentConstraint1.w1" "ctrl_j_l_femur_parentConstraint1.tg[1].tw"
		;
connectAttr "right.di" "ctrl_r_foot.do";
connectAttr "IK_ctrl_j_r_femur.msg" "ik_r_leg.hsj";
connectAttr "effector3.hp" "ik_r_leg.hee";
connectAttr "ikRPsolver.msg" "ik_r_leg.hsv";
connectAttr "ik_r_leg_poleVectorConstraint1.ctx" "ik_r_leg.pvx";
connectAttr "ik_r_leg_poleVectorConstraint1.cty" "ik_r_leg.pvy";
connectAttr "ik_r_leg_poleVectorConstraint1.ctz" "ik_r_leg.pvz";
connectAttr "IK_ctrl_j_r_foot.msg" "ik_r_foot.hsj";
connectAttr "effector4.hp" "ik_r_foot.hee";
connectAttr "ikRPsolver.msg" "ik_r_foot.hsv";
connectAttr "ik_r_leg.pim" "ik_r_leg_poleVectorConstraint1.cpim";
connectAttr "IK_ctrl_j_r_femur.pm" "ik_r_leg_poleVectorConstraint1.ps";
connectAttr "IK_ctrl_j_r_femur.t" "ik_r_leg_poleVectorConstraint1.crp";
connectAttr "ctrl_r_leg_PV.t" "ik_r_leg_poleVectorConstraint1.tg[0].tt";
connectAttr "ctrl_r_leg_PV.rp" "ik_r_leg_poleVectorConstraint1.tg[0].trp";
connectAttr "ctrl_r_leg_PV.rpt" "ik_r_leg_poleVectorConstraint1.tg[0].trt";
connectAttr "ctrl_r_leg_PV.pm" "ik_r_leg_poleVectorConstraint1.tg[0].tpm";
connectAttr "ik_r_leg_poleVectorConstraint1.w0" "ik_r_leg_poleVectorConstraint1.tg[0].tw"
		;
connectAttr "right.di" "ctrl_r_leg_PV.do";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.ctx" "IK_ctrl_j_r_femur.tx";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.cty" "IK_ctrl_j_r_femur.ty";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.ctz" "IK_ctrl_j_r_femur.tz";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.crx" "IK_ctrl_j_r_femur.rx";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.cry" "IK_ctrl_j_r_femur.ry";
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.crz" "IK_ctrl_j_r_femur.rz";
connectAttr "IK_ctrl_j_r_femur.s" "IK_ctrl_j_r_knee.is";
connectAttr "IK_ctrl_j_r_knee.s" "IK_ctrl_j_r_heel.is";
connectAttr "IK_ctrl_j_r_heel.s" "IK_ctrl_j_r_foot.is";
connectAttr "IK_ctrl_j_r_foot.s" "IK_ctrl_j_r_toe.is";
connectAttr "IK_ctrl_j_r_toe.tx" "effector4.tx";
connectAttr "IK_ctrl_j_r_toe.ty" "effector4.ty";
connectAttr "IK_ctrl_j_r_toe.tz" "effector4.tz";
connectAttr "IK_ctrl_j_r_foot.tx" "effector3.tx";
connectAttr "IK_ctrl_j_r_foot.ty" "effector3.ty";
connectAttr "IK_ctrl_j_r_foot.tz" "effector3.tz";
connectAttr "IK_ctrl_j_r_femur.ro" "IK_ctrl_j_r_femur_parentConstraint1.cro";
connectAttr "IK_ctrl_j_r_femur.pim" "IK_ctrl_j_r_femur_parentConstraint1.cpim";
connectAttr "IK_ctrl_j_r_femur.rp" "IK_ctrl_j_r_femur_parentConstraint1.crp";
connectAttr "IK_ctrl_j_r_femur.rpt" "IK_ctrl_j_r_femur_parentConstraint1.crt";
connectAttr "IK_ctrl_j_r_femur.jo" "IK_ctrl_j_r_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_pelvis_low.t" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tt"
		;
connectAttr "ctrl_j_pelvis_low.rp" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].trp"
		;
connectAttr "ctrl_j_pelvis_low.rpt" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_j_pelvis_low.r" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tr"
		;
connectAttr "ctrl_j_pelvis_low.ro" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tro"
		;
connectAttr "ctrl_j_pelvis_low.s" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].ts"
		;
connectAttr "ctrl_j_pelvis_low.pm" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tpm"
		;
connectAttr "ctrl_j_pelvis_low.jo" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tjo"
		;
connectAttr "ctrl_j_pelvis_low.ssc" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tsc"
		;
connectAttr "ctrl_j_pelvis_low.is" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tis"
		;
connectAttr "IK_ctrl_j_r_femur_parentConstraint1.w0" "IK_ctrl_j_r_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_femur_parentConstraint1.ctx" "ctrl_j_r_femur.tx";
connectAttr "ctrl_j_r_femur_parentConstraint1.cty" "ctrl_j_r_femur.ty";
connectAttr "ctrl_j_r_femur_parentConstraint1.ctz" "ctrl_j_r_femur.tz";
connectAttr "ctrl_j_r_femur_parentConstraint1.crx" "ctrl_j_r_femur.rx";
connectAttr "ctrl_j_r_femur_parentConstraint1.cry" "ctrl_j_r_femur.ry";
connectAttr "ctrl_j_r_femur_parentConstraint1.crz" "ctrl_j_r_femur.rz";
connectAttr "ctrl_j_r_knee_parentConstraint1.ctx" "ctrl_j_r_knee.tx";
connectAttr "ctrl_j_r_knee_parentConstraint1.cty" "ctrl_j_r_knee.ty";
connectAttr "ctrl_j_r_knee_parentConstraint1.ctz" "ctrl_j_r_knee.tz";
connectAttr "ctrl_j_r_knee_parentConstraint1.crx" "ctrl_j_r_knee.rx";
connectAttr "ctrl_j_r_knee_parentConstraint1.cry" "ctrl_j_r_knee.ry";
connectAttr "ctrl_j_r_knee_parentConstraint1.crz" "ctrl_j_r_knee.rz";
connectAttr "ctrl_j_r_femur.s" "ctrl_j_r_knee.is";
connectAttr "ctrl_j_r_heel_parentConstraint1.ctx" "ctrl_j_r_heel.tx";
connectAttr "ctrl_j_r_heel_parentConstraint1.cty" "ctrl_j_r_heel.ty";
connectAttr "ctrl_j_r_heel_parentConstraint1.ctz" "ctrl_j_r_heel.tz";
connectAttr "ctrl_j_r_heel_parentConstraint1.crx" "ctrl_j_r_heel.rx";
connectAttr "ctrl_j_r_heel_parentConstraint1.cry" "ctrl_j_r_heel.ry";
connectAttr "ctrl_j_r_heel_parentConstraint1.crz" "ctrl_j_r_heel.rz";
connectAttr "ctrl_j_r_knee.s" "ctrl_j_r_heel.is";
connectAttr "ctrl_j_r_foot_parentConstraint1.ctx" "ctrl_j_r_foot.tx";
connectAttr "ctrl_j_r_foot_parentConstraint1.cty" "ctrl_j_r_foot.ty";
connectAttr "ctrl_j_r_foot_parentConstraint1.ctz" "ctrl_j_r_foot.tz";
connectAttr "ctrl_j_r_foot_parentConstraint1.crx" "ctrl_j_r_foot.rx";
connectAttr "ctrl_j_r_foot_parentConstraint1.cry" "ctrl_j_r_foot.ry";
connectAttr "ctrl_j_r_foot_parentConstraint1.crz" "ctrl_j_r_foot.rz";
connectAttr "ctrl_j_r_heel.s" "ctrl_j_r_foot.is";
connectAttr "ctrl_j_r_toe_parentConstraint1.ctx" "ctrl_j_r_toe.tx";
connectAttr "ctrl_j_r_toe_parentConstraint1.cty" "ctrl_j_r_toe.ty";
connectAttr "ctrl_j_r_toe_parentConstraint1.ctz" "ctrl_j_r_toe.tz";
connectAttr "ctrl_j_r_toe_parentConstraint1.crx" "ctrl_j_r_toe.rx";
connectAttr "ctrl_j_r_toe_parentConstraint1.cry" "ctrl_j_r_toe.ry";
connectAttr "ctrl_j_r_toe_parentConstraint1.crz" "ctrl_j_r_toe.rz";
connectAttr "ctrl_j_r_foot.s" "ctrl_j_r_toe.is";
connectAttr "ctrl_j_r_toe.ro" "ctrl_j_r_toe_parentConstraint1.cro";
connectAttr "ctrl_j_r_toe.pim" "ctrl_j_r_toe_parentConstraint1.cpim";
connectAttr "ctrl_j_r_toe.rp" "ctrl_j_r_toe_parentConstraint1.crp";
connectAttr "ctrl_j_r_toe.rpt" "ctrl_j_r_toe_parentConstraint1.crt";
connectAttr "ctrl_j_r_toe.jo" "ctrl_j_r_toe_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_r_toe.t" "ctrl_j_r_toe_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_r_toe.rp" "ctrl_j_r_toe_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_r_toe.rpt" "ctrl_j_r_toe_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_r_toe.r" "ctrl_j_r_toe_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_r_toe.ro" "ctrl_j_r_toe_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_r_toe.s" "ctrl_j_r_toe_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_r_toe.pm" "ctrl_j_r_toe_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_r_toe.jo" "ctrl_j_r_toe_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_r_toe.ssc" "ctrl_j_r_toe_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_r_toe.is" "ctrl_j_r_toe_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_r_toe_parentConstraint1.w0" "ctrl_j_r_toe_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_foot.ro" "ctrl_j_r_foot_parentConstraint1.cro";
connectAttr "ctrl_j_r_foot.pim" "ctrl_j_r_foot_parentConstraint1.cpim";
connectAttr "ctrl_j_r_foot.rp" "ctrl_j_r_foot_parentConstraint1.crp";
connectAttr "ctrl_j_r_foot.rpt" "ctrl_j_r_foot_parentConstraint1.crt";
connectAttr "ctrl_j_r_foot.jo" "ctrl_j_r_foot_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_r_foot.t" "ctrl_j_r_foot_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_r_foot.rp" "ctrl_j_r_foot_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_r_foot.rpt" "ctrl_j_r_foot_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_r_foot.r" "ctrl_j_r_foot_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_r_foot.ro" "ctrl_j_r_foot_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_r_foot.s" "ctrl_j_r_foot_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_r_foot.pm" "ctrl_j_r_foot_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_r_foot.jo" "ctrl_j_r_foot_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_r_foot.ssc" "ctrl_j_r_foot_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_r_foot.is" "ctrl_j_r_foot_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_r_foot_parentConstraint1.w0" "ctrl_j_r_foot_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_heel.ro" "ctrl_j_r_heel_parentConstraint1.cro";
connectAttr "ctrl_j_r_heel.pim" "ctrl_j_r_heel_parentConstraint1.cpim";
connectAttr "ctrl_j_r_heel.rp" "ctrl_j_r_heel_parentConstraint1.crp";
connectAttr "ctrl_j_r_heel.rpt" "ctrl_j_r_heel_parentConstraint1.crt";
connectAttr "ctrl_j_r_heel.jo" "ctrl_j_r_heel_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_r_heel.t" "ctrl_j_r_heel_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_r_heel.rp" "ctrl_j_r_heel_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_r_heel.rpt" "ctrl_j_r_heel_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_r_heel.r" "ctrl_j_r_heel_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_r_heel.ro" "ctrl_j_r_heel_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_r_heel.s" "ctrl_j_r_heel_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_r_heel.pm" "ctrl_j_r_heel_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_r_heel.jo" "ctrl_j_r_heel_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_r_heel.ssc" "ctrl_j_r_heel_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_r_heel.is" "ctrl_j_r_heel_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_r_heel_parentConstraint1.w0" "ctrl_j_r_heel_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_knee.ro" "ctrl_j_r_knee_parentConstraint1.cro";
connectAttr "ctrl_j_r_knee.pim" "ctrl_j_r_knee_parentConstraint1.cpim";
connectAttr "ctrl_j_r_knee.rp" "ctrl_j_r_knee_parentConstraint1.crp";
connectAttr "ctrl_j_r_knee.rpt" "ctrl_j_r_knee_parentConstraint1.crt";
connectAttr "ctrl_j_r_knee.jo" "ctrl_j_r_knee_parentConstraint1.cjo";
connectAttr "IK_ctrl_j_r_knee.t" "ctrl_j_r_knee_parentConstraint1.tg[0].tt";
connectAttr "IK_ctrl_j_r_knee.rp" "ctrl_j_r_knee_parentConstraint1.tg[0].trp";
connectAttr "IK_ctrl_j_r_knee.rpt" "ctrl_j_r_knee_parentConstraint1.tg[0].trt";
connectAttr "IK_ctrl_j_r_knee.r" "ctrl_j_r_knee_parentConstraint1.tg[0].tr";
connectAttr "IK_ctrl_j_r_knee.ro" "ctrl_j_r_knee_parentConstraint1.tg[0].tro";
connectAttr "IK_ctrl_j_r_knee.s" "ctrl_j_r_knee_parentConstraint1.tg[0].ts";
connectAttr "IK_ctrl_j_r_knee.pm" "ctrl_j_r_knee_parentConstraint1.tg[0].tpm";
connectAttr "IK_ctrl_j_r_knee.jo" "ctrl_j_r_knee_parentConstraint1.tg[0].tjo";
connectAttr "IK_ctrl_j_r_knee.ssc" "ctrl_j_r_knee_parentConstraint1.tg[0].tsc";
connectAttr "IK_ctrl_j_r_knee.is" "ctrl_j_r_knee_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_r_knee_parentConstraint1.w0" "ctrl_j_r_knee_parentConstraint1.tg[0].tw"
		;
connectAttr "ctrl_j_r_femur.ro" "ctrl_j_r_femur_parentConstraint1.cro";
connectAttr "ctrl_j_r_femur.pim" "ctrl_j_r_femur_parentConstraint1.cpim";
connectAttr "ctrl_j_r_femur.rp" "ctrl_j_r_femur_parentConstraint1.crp";
connectAttr "ctrl_j_r_femur.rpt" "ctrl_j_r_femur_parentConstraint1.crt";
connectAttr "ctrl_j_r_femur.jo" "ctrl_j_r_femur_parentConstraint1.cjo";
connectAttr "ctrl_j_pelvis_low.t" "ctrl_j_r_femur_parentConstraint1.tg[0].tt";
connectAttr "ctrl_j_pelvis_low.rp" "ctrl_j_r_femur_parentConstraint1.tg[0].trp";
connectAttr "ctrl_j_pelvis_low.rpt" "ctrl_j_r_femur_parentConstraint1.tg[0].trt"
		;
connectAttr "ctrl_j_pelvis_low.r" "ctrl_j_r_femur_parentConstraint1.tg[0].tr";
connectAttr "ctrl_j_pelvis_low.ro" "ctrl_j_r_femur_parentConstraint1.tg[0].tro";
connectAttr "ctrl_j_pelvis_low.s" "ctrl_j_r_femur_parentConstraint1.tg[0].ts";
connectAttr "ctrl_j_pelvis_low.pm" "ctrl_j_r_femur_parentConstraint1.tg[0].tpm";
connectAttr "ctrl_j_pelvis_low.jo" "ctrl_j_r_femur_parentConstraint1.tg[0].tjo";
connectAttr "ctrl_j_pelvis_low.ssc" "ctrl_j_r_femur_parentConstraint1.tg[0].tsc"
		;
connectAttr "ctrl_j_pelvis_low.is" "ctrl_j_r_femur_parentConstraint1.tg[0].tis";
connectAttr "ctrl_j_r_femur_parentConstraint1.w0" "ctrl_j_r_femur_parentConstraint1.tg[0].tw"
		;
connectAttr "IK_ctrl_j_r_femur.t" "ctrl_j_r_femur_parentConstraint1.tg[1].tt";
connectAttr "IK_ctrl_j_r_femur.rp" "ctrl_j_r_femur_parentConstraint1.tg[1].trp";
connectAttr "IK_ctrl_j_r_femur.rpt" "ctrl_j_r_femur_parentConstraint1.tg[1].trt"
		;
connectAttr "IK_ctrl_j_r_femur.r" "ctrl_j_r_femur_parentConstraint1.tg[1].tr";
connectAttr "IK_ctrl_j_r_femur.ro" "ctrl_j_r_femur_parentConstraint1.tg[1].tro";
connectAttr "IK_ctrl_j_r_femur.s" "ctrl_j_r_femur_parentConstraint1.tg[1].ts";
connectAttr "IK_ctrl_j_r_femur.pm" "ctrl_j_r_femur_parentConstraint1.tg[1].tpm";
connectAttr "IK_ctrl_j_r_femur.jo" "ctrl_j_r_femur_parentConstraint1.tg[1].tjo";
connectAttr "IK_ctrl_j_r_femur.ssc" "ctrl_j_r_femur_parentConstraint1.tg[1].tsc"
		;
connectAttr "IK_ctrl_j_r_femur.is" "ctrl_j_r_femur_parentConstraint1.tg[1].tis";
connectAttr "ctrl_j_r_femur_parentConstraint1.w1" "ctrl_j_r_femur_parentConstraint1.tg[1].tw"
		;
relationship "link" ":lightLinker1" ":initialShadingGroup.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" ":initialParticleSE.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "catlow:Default.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "playerstartSG.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "playerstartSG1.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "surfaceShader1SG.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "surfaceShader2SG.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "surfaceShader3SG.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "surfaceShader4SG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" ":initialShadingGroup.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" ":initialParticleSE.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "catlow:Default.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "playerstartSG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "playerstartSG1.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "surfaceShader1SG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "surfaceShader2SG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "surfaceShader3SG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "surfaceShader4SG.message" ":defaultLightSet.message";
connectAttr "layerManager.dli[0]" "defaultLayer.id";
connectAttr "renderLayerManager.rlmi[0]" "defaultRenderLayer.rlid";
connectAttr "catlow:Default.msg" "catlow:materialInfo1.sg";
connectAttr ":TurtleDefaultBakeLayer.idx" ":TurtleBakeLayerManager.bli[0]";
connectAttr ":TurtleRenderOptions.msg" ":TurtleDefaultBakeLayer.rset";
connectAttr "playerstartSG.msg" "materialInfo1.sg";
connectAttr "playerstartSG1.msg" "materialInfo2.sg";
connectAttr "place2dTexture1.o" "EditorFBXASC047orangeFBXASC046vtf.uv";
connectAttr "place2dTexture1.ofu" "EditorFBXASC047orangeFBXASC046vtf.ofu";
connectAttr "place2dTexture1.ofv" "EditorFBXASC047orangeFBXASC046vtf.ofv";
connectAttr "place2dTexture1.rf" "EditorFBXASC047orangeFBXASC046vtf.rf";
connectAttr "place2dTexture1.reu" "EditorFBXASC047orangeFBXASC046vtf.reu";
connectAttr "place2dTexture1.rev" "EditorFBXASC047orangeFBXASC046vtf.rev";
connectAttr "place2dTexture1.vt1" "EditorFBXASC047orangeFBXASC046vtf.vt1";
connectAttr "place2dTexture1.vt2" "EditorFBXASC047orangeFBXASC046vtf.vt2";
connectAttr "place2dTexture1.vt3" "EditorFBXASC047orangeFBXASC046vtf.vt3";
connectAttr "place2dTexture1.vc1" "EditorFBXASC047orangeFBXASC046vtf.vc1";
connectAttr "place2dTexture1.ofs" "EditorFBXASC047orangeFBXASC046vtf.fs";
connectAttr "place2dTexture2.o" "EditorFBXASC047grayFBXASC046vtf.uv";
connectAttr "place2dTexture2.ofu" "EditorFBXASC047grayFBXASC046vtf.ofu";
connectAttr "place2dTexture2.ofv" "EditorFBXASC047grayFBXASC046vtf.ofv";
connectAttr "place2dTexture2.rf" "EditorFBXASC047grayFBXASC046vtf.rf";
connectAttr "place2dTexture2.reu" "EditorFBXASC047grayFBXASC046vtf.reu";
connectAttr "place2dTexture2.rev" "EditorFBXASC047grayFBXASC046vtf.rev";
connectAttr "place2dTexture2.vt1" "EditorFBXASC047grayFBXASC046vtf.vt1";
connectAttr "place2dTexture2.vt2" "EditorFBXASC047grayFBXASC046vtf.vt2";
connectAttr "place2dTexture2.vt3" "EditorFBXASC047grayFBXASC046vtf.vt3";
connectAttr "place2dTexture2.vc1" "EditorFBXASC047grayFBXASC046vtf.vc1";
connectAttr "place2dTexture2.ofs" "EditorFBXASC047grayFBXASC046vtf.fs";
connectAttr "skinCluster1GroupParts.og" "skinCluster1.ip[0].ig";
connectAttr "skinCluster1GroupId.id" "skinCluster1.ip[0].gi";
connectAttr "bindPose1.msg" "skinCluster1.bp";
connectAttr "ik_j_spine_03.wm" "skinCluster1.ma[0]";
connectAttr "ik_j_pelvis.wm" "skinCluster1.ma[1]";
connectAttr "ik_j_spine_03.liw" "skinCluster1.lw[0]";
connectAttr "ik_j_pelvis.liw" "skinCluster1.lw[1]";
connectAttr "ik_j_spine_03.obcc" "skinCluster1.ifcl[0]";
connectAttr "ik_j_pelvis.obcc" "skinCluster1.ifcl[1]";
connectAttr "groupParts2.og" "tweak1.ip[0].ig";
connectAttr "groupId55.id" "tweak1.ip[0].gi";
connectAttr "skinCluster1GroupId.msg" "skinCluster1Set.gn" -na;
connectAttr "crv_spineShape.iog.og[0]" "skinCluster1Set.dsm" -na;
connectAttr "skinCluster1.msg" "skinCluster1Set.ub[0]";
connectAttr "tweak1.og[0]" "skinCluster1GroupParts.ig";
connectAttr "skinCluster1GroupId.id" "skinCluster1GroupParts.gi";
connectAttr "groupId55.msg" "tweakSet1.gn" -na;
connectAttr "crv_spineShape.iog.og[1]" "tweakSet1.dsm" -na;
connectAttr "tweak1.msg" "tweakSet1.ub[0]";
connectAttr "crv_spineShapeOrig.ws" "groupParts2.ig";
connectAttr "groupId55.id" "groupParts2.gi";
connectAttr "ik_j_spine_03.msg" "bindPose1.m[0]";
connectAttr "ik_j_pelvis.msg" "bindPose1.m[1]";
connectAttr "bindPose1.w" "bindPose1.p[0]";
connectAttr "bindPose1.w" "bindPose1.p[1]";
connectAttr "ik_j_spine_03.bps" "bindPose1.wm[0]";
connectAttr "ik_j_pelvis.bps" "bindPose1.wm[1]";
connectAttr "crv_spineShape.ws" "spine_curveInfo.ic";
connectAttr "spine_curveInfo.al" "plusMinusAverage1.i1[0]";
connectAttr "plusMinusAverage1.o1" "multiplyDivide1.i1x";
connectAttr "multiplyDivide1.ox" "spine_03_plus.i1[0]";
connectAttr "multiplyDivide1.ox" "spine_01_plus.i1[0]";
connectAttr "multiplyDivide1.ox" "spine_02_plus.i1[0]";
connectAttr "ctrl_head.Follow" "rev_head_const.ix";
connectAttr "surfaceShader1.oc" "surfaceShader1SG.ss";
connectAttr "ctrl_headShape.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_neckShape.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_spine_0Shape3.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_spine_0Shape2.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_spine_0Shape1.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_pelvisShape.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "ctrl_pelvis_lowShape.iog.og[0]" "surfaceShader1SG.dsm" -na;
connectAttr "groupId65.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId66.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId15.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId16.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId17.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId59.msg" "surfaceShader1SG.gn" -na;
connectAttr "groupId60.msg" "surfaceShader1SG.gn" -na;
connectAttr "surfaceShader1SG.msg" "materialInfo3.sg";
connectAttr "surfaceShader1.msg" "materialInfo3.m";
connectAttr "surfaceShader1.msg" "materialInfo3.t" -na;
connectAttr "layerManager.dli[1]" "spine.id";
connectAttr "surfaceShader2.oc" "surfaceShader2SG.ss";
connectAttr "ctrl_tail_0Shape5.iog" "surfaceShader2SG.dsm" -na;
connectAttr "ctrl_tail_0Shape4.iog" "surfaceShader2SG.dsm" -na;
connectAttr "ctrl_tail_0Shape3.iog" "surfaceShader2SG.dsm" -na;
connectAttr "ctrl_tail_0Shape2.iog" "surfaceShader2SG.dsm" -na;
connectAttr "ctrl_tail_0Shape1.iog" "surfaceShader2SG.dsm" -na;
connectAttr "surfaceShader2SG.msg" "materialInfo4.sg";
connectAttr "surfaceShader2.msg" "materialInfo4.m";
connectAttr "surfaceShader2.msg" "materialInfo4.t" -na;
connectAttr "layerManager.dli[2]" "tail.id";
connectAttr "layerManager.dli[3]" "left.id";
connectAttr "layerManager.dli[4]" "head.id";
connectAttr "surfaceShader3.oc" "surfaceShader3SG.ss";
connectAttr "ctrl_l_clavicleShape.iog" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_shoulderShape.iog" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_elbowShape.iog" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_wristShape.iog" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_footShape.iog" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_ear_0Shape2.iog.og[0]" "surfaceShader3SG.dsm" -na;
connectAttr "ctrl_l_ear_0Shape1.iog.og[0]" "surfaceShader3SG.dsm" -na;
connectAttr "groupId75.msg" "surfaceShader3SG.gn" -na;
connectAttr "groupId76.msg" "surfaceShader3SG.gn" -na;
connectAttr "surfaceShader3SG.msg" "materialInfo5.sg";
connectAttr "surfaceShader3.msg" "materialInfo5.m";
connectAttr "surfaceShader3.msg" "materialInfo5.t" -na;
connectAttr "layerManager.dli[5]" "right.id";
connectAttr "surfaceShader4.oc" "surfaceShader4SG.ss";
connectAttr "ctrl_r_clavicleShape.iog" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_wristShape.iog" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_elbowShape.iog" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_shoulderShape.iog" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_footShape.iog" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_ear_0Shape1.iog.og[0]" "surfaceShader4SG.dsm" -na;
connectAttr "ctrl_r_ear_0Shape2.iog.og[0]" "surfaceShader4SG.dsm" -na;
connectAttr "groupId77.msg" "surfaceShader4SG.gn" -na;
connectAttr "groupId78.msg" "surfaceShader4SG.gn" -na;
connectAttr "surfaceShader4SG.msg" "materialInfo6.sg";
connectAttr "surfaceShader4.msg" "materialInfo6.m";
connectAttr "surfaceShader4.msg" "materialInfo6.t" -na;
connectAttr ":defaultArnoldDisplayDriver.msg" ":defaultArnoldRenderOptions.drivers"
		 -na;
connectAttr ":defaultArnoldFilter.msg" ":defaultArnoldRenderOptions.filt";
connectAttr ":defaultArnoldDriver.msg" ":defaultArnoldRenderOptions.drvr";
connectAttr "ctrl_j_pelvis_low.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[4].dn"
		;
connectAttr "rev_head_const.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[5].dn";
connectAttr "ctrl_head.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[6].dn";
connectAttr "prnt_head_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[7].dn"
		;
connectAttr "surfaceShader1SG.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[8].dn"
		;
connectAttr "ctrl_headShape.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[9].dn";
connectAttr "surfaceShader1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[12].dn";
connectAttr "spine.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[25].dn";
connectAttr "j_tail_05_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[27].dn"
		;
connectAttr "surfaceShader2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[29].dn";
connectAttr "surfaceShader2SG.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[30].dn"
		;
connectAttr "ctrl_tail_01_blendParent1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[41].dn"
		;
connectAttr "j_spine_03_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[47].dn"
		;
connectAttr "ctrl_l_leg_PV.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[49].dn";
connectAttr "ctrl_l_leg_PVShape1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[51].dn"
		;
connectAttr "ctrl_l_leg_PVShape.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[55].dn"
		;
connectAttr "ctrl_r_leg_PVShape2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[57].dn"
		;
connectAttr "ctrl_l_leg_PVShape2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[58].dn"
		;
connectAttr "ctrl_r_leg_PVShape.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[60].dn"
		;
connectAttr "ctrl_r_leg_PV.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[63].dn";
connectAttr "ctrl_r_leg_PVShape1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[64].dn"
		;
connectAttr "ctrl_j_tail_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[78].dn";
connectAttr "ctrl_j_tail_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[79].dn";
connectAttr "ctrl_j_tail_05.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[82].dn";
connectAttr "ctrl_j_tail_04.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[83].dn";
connectAttr "ctrl_j_tail_03.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[84].dn";
connectAttr "ctrl_j_r_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[85].dn";
connectAttr "ctrl_j_r_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[86].dn";
connectAttr "ctrl_j_r_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[87].dn"
		;
connectAttr "ctrl_j_r_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[88].dn"
		;
connectAttr "ctrl_j_l_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[89].dn";
connectAttr "ctrl_j_l_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[90].dn"
		;
connectAttr "ctrl_j_l_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[91].dn"
		;
connectAttr "ctrl_j_l_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[94].dn";
connectAttr "j_l_clavicle_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[97].dn"
		;
connectAttr "j_l_shoulder_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[98].dn"
		;
connectAttr "j_tail_03_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[99].dn"
		;
connectAttr "ctrl_j_tail_05_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[101].dn"
		;
connectAttr "j_r_elbow_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[102].dn"
		;
connectAttr "ctrl_j_tail_03_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[103].dn"
		;
connectAttr "j_l_elbow_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[104].dn"
		;
connectAttr "offset_l_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[105].dn"
		;
connectAttr "ctrl_j_tail_04_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[106].dn"
		;
connectAttr "ctrl_j_tail_02_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[107].dn"
		;
connectAttr "j_l_wrist_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[108].dn"
		;
connectAttr "j_r_clavicle_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[109].dn"
		;
connectAttr "j_r_shoulder_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[110].dn"
		;
connectAttr "j_r_wrist_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[111].dn"
		;
connectAttr "prnt_l_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[113].dn";
connectAttr "ctrl_j_l_wrist_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[114].dn"
		;
connectAttr "offset_l_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[116].dn"
		;
connectAttr "offset_l_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[117].dn"
		;
connectAttr "j_tail_02_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[118].dn"
		;
connectAttr "offset_r_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[119].dn"
		;
connectAttr "prnt_r_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[120].dn"
		;
connectAttr "prnt_l_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[121].dn";
connectAttr "prnt_l_shoulder.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[122].dn"
		;
connectAttr "j_tail_01_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[124].dn"
		;
connectAttr "offset_r_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[125].dn"
		;
connectAttr "prnt_r_elbow.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[126].dn";
connectAttr "offset_l_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[127].dn"
		;
connectAttr "prnt_l_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[128].dn"
		;
connectAttr "offset_r_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[130].dn"
		;
connectAttr "prnt_r_clavicle.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[131].dn"
		;
connectAttr "ctrl_j_r_wrist_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[132].dn"
		;
connectAttr "ctrl_j_r_shoulder_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[133].dn"
		;
connectAttr "prnt_r_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[134].dn";
connectAttr "offset_r_wrist.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[135].dn"
		;
connectAttr "ctrl_j_r_clavicle_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[136].dn"
		;
connectAttr "ctrl_j_l_elbow_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[137].dn"
		;
connectAttr "ctrl_j_r_elbow_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[138].dn"
		;
connectAttr "ctrl_j_l_shoulder_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[139].dn"
		;
connectAttr "ctrl_j_l_clavicle_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[140].dn"
		;
connectAttr "j_tail_04_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[141].dn"
		;
connectAttr "tail.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[143].dn";
connectAttr "left.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[145].dn";
connectAttr "head.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[146].dn";
connectAttr "surfaceShader3SG.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[149].dn"
		;
connectAttr "surfaceShader3.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[150].dn"
		;
connectAttr "right.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[151].dn";
connectAttr "ctrl_j_pelvis_low_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[152].dn"
		;
connectAttr "surfaceShader4.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[153].dn"
		;
connectAttr "surfaceShader4SG.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[154].dn"
		;
connectAttr ":defaultArnoldDriver.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[155].dn"
		;
connectAttr ":defaultArnoldDisplayDriver.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[156].dn"
		;
connectAttr ":defaultArnoldRenderOptions.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[157].dn"
		;
connectAttr ":defaultArnoldFilter.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[159].dn"
		;
connectAttr "ctrl_root.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[160].dn";
connectAttr "ctrl_rootShape2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[161].dn"
		;
connectAttr "prnt_root.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[162].dn";
connectAttr "offset_root.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[163].dn";
connectAttr "makeNurbCircle9.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[164].dn"
		;
connectAttr "ctrl_rootShape.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[165].dn"
		;
connectAttr "grp_l_arm.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[166].dn";
connectAttr "makeNurbCircle10.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[167].dn"
		;
connectAttr "ctrl_rootShape1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[168].dn"
		;
connectAttr "makeNurbCircle11.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[169].dn"
		;
connectAttr "grp_r_arm.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[170].dn";
connectAttr "j_spine_01_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[171].dn"
		;
connectAttr "grp_r_leg.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[172].dn";
connectAttr "grp_l_leg.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[175].dn";
connectAttr "j_spine_02_parentConstraint1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[176].dn"
		;
connectAttr "ctrl_l_ear_0Shape1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[177].dn"
		;
connectAttr "offset_l_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[178].dn"
		;
connectAttr "prnt_l_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[179].dn";
connectAttr "ctrl_r_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[180].dn";
connectAttr "ctrl_l_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[181].dn";
connectAttr "ctrl_l_ear_0Shape2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[182].dn"
		;
connectAttr "ctrl_l_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[183].dn";
connectAttr "ctrl_r_ear_0Shape2.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[184].dn"
		;
connectAttr "ctrl_r_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[185].dn";
connectAttr "ctrl_r_ear_0Shape1.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[186].dn"
		;
connectAttr "prnt_l_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[190].dn";
connectAttr "offset_r_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[191].dn"
		;
connectAttr "ctrl_j_r_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[192].dn"
		;
connectAttr "ctrl_j_r_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[193].dn"
		;
connectAttr "ctrl_j_l_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[194].dn"
		;
connectAttr "ctrl_j_l_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[195].dn"
		;
connectAttr "offset_l_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[197].dn"
		;
connectAttr "prnt_r_ear_01.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[198].dn";
connectAttr "offset_r_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[199].dn"
		;
connectAttr "prnt_r_ear_02.msg" "MayaNodeEditorSavedTabsInfo.tgi[0].ni[200].dn";
connectAttr "layerManager.dli[7]" "skeleton.id";
connectAttr "catlow:Default.pa" ":renderPartition.st" -na;
connectAttr "playerstartSG.pa" ":renderPartition.st" -na;
connectAttr "playerstartSG1.pa" ":renderPartition.st" -na;
connectAttr "surfaceShader1SG.pa" ":renderPartition.st" -na;
connectAttr "surfaceShader2SG.pa" ":renderPartition.st" -na;
connectAttr "surfaceShader3SG.pa" ":renderPartition.st" -na;
connectAttr "surfaceShader4SG.pa" ":renderPartition.st" -na;
connectAttr "surfaceShader1.msg" ":defaultShaderList1.s" -na;
connectAttr "surfaceShader2.msg" ":defaultShaderList1.s" -na;
connectAttr "surfaceShader3.msg" ":defaultShaderList1.s" -na;
connectAttr "surfaceShader4.msg" ":defaultShaderList1.s" -na;
connectAttr "place2dTexture1.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "place2dTexture2.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "spine_curveInfo.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "plusMinusAverage1.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "multiplyDivide1.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "spine_03_plus.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "spine_01_plus.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "spine_02_plus.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "rev_head_const.msg" ":defaultRenderUtilityList1.u" -na;
connectAttr "defaultRenderLayer.msg" ":defaultRenderingList1.r" -na;
connectAttr "EditorFBXASC047orangeFBXASC046vtf.msg" ":defaultTextureList1.tx" -na
		;
connectAttr "EditorFBXASC047grayFBXASC046vtf.msg" ":defaultTextureList1.tx" -na;
connectAttr "ikSplineSolver.msg" ":ikSystem.sol" -na;
connectAttr "ikRPsolver.msg" ":ikSystem.sol" -na;
// End of rig_cat.ma
