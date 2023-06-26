module i2c_hub_x4
(
//主从接口
	input     upstream0_scl_T,
	input     upstream0_scl_I,
	output    upstream0_scl_O,
	input     upstream0_sda_T,
	input     upstream0_sda_I,
	output    upstream0_sda_O,
    
//从机接口 1   
	input     upstream1_scl_T,
	input     upstream1_scl_I,
	output    upstream1_scl_O,
	input     upstream1_sda_T,
	input     upstream1_sda_I,
	output    upstream1_sda_O,
//从机接口 2   
    input     upstream2_scl_T,
	input     upstream2_scl_I,
	output    upstream2_scl_O,
	input     upstream2_sda_T,
	input     upstream2_sda_I,
	output    upstream2_sda_O,

//从机接口 3   
    input     upstream3_scl_T,
	input     upstream3_scl_I,
	output    upstream3_scl_O,
	input     upstream3_sda_T,
	input     upstream3_sda_I,
	output    upstream3_sda_O,
	
	
	output    downstream_scl_T,
	input     downstream_scl_I,
	output    downstream_scl_O,
	output    downstream_sda_T,
	input     downstream_sda_I,
	output    downstream_sda_O
);
/*
三态门中，T为0时，代表输出，为1，代表输入

*/
//assign downstream_scl_T = upstream0_scl_T & upstream1_scl_T;
//assign downstream_scl_O = (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I);
//assign downstream_sda_T = upstream0_sda_T & upstream1_sda_T;
//assign downstream_sda_O = (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I);
// follows for spec proj
//assign upstream0_scl_O = downstream_scl_I;
//assign upstream0_sda_O = downstream_sda_I;
//assign upstream1_scl_O = downstream_scl_I;
//assign upstream1_sda_O = downstream_sda_I;
//// follows for spec proj
////assign upstream0_scl_O = downstream_scl_I & upstream1_scl_I;
////assign upstream0_sda_O = downstream_sda_I & upstream1_sda_I;
////assign upstream1_scl_O = downstream_scl_I & upstream0_scl_I;
////assign upstream1_sda_O = downstream_sda_I & upstream0_sda_I;

/*
assign downstream_scl_T = upstream0_scl_T & upstream1_scl_T & upstream2_scl_T;
assign downstream_scl_O = (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I) & (upstream2_scl_T ? 1'b1 : upstream2_scl_I);
assign upstream0_scl_O=((upstream0_scl_T & upstream1_scl_T & upstream2_scl_T) ? downstream_scl_I : 1'b1) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I) & (upstream2_scl_T ? 1'b1 : upstream2_scl_I);
assign upstream1_scl_O=((upstream0_scl_T & upstream1_scl_T & upstream2_scl_T) ? downstream_scl_I : 1'b1) & (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream2_scl_T ? 1'b1 : upstream2_scl_I);
assign upstream2_scl_O=((upstream0_scl_T & upstream1_scl_T & upstream2_scl_T) ? downstream_scl_I : 1'b1) & (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I);

assign downstream_sda_T = upstream0_sda_T & upstream1_sda_T & upstream2_sda_T;
assign downstream_sda_O = (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I) & (upstream2_sda_T ? 1'b1 : upstream2_sda_I);
assign upstream0_sda_O=((upstream0_sda_T & upstream1_sda_T & upstream2_sda_T) ? downstream_sda_I : 1'b1) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I) & (upstream2_sda_T ? 1'b1 : upstream2_sda_I);
assign upstream1_sda_O=((upstream0_sda_T & upstream1_sda_T & upstream2_sda_T) ? downstream_sda_I : 1'b1) & (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream2_sda_T ? 1'b1 : upstream2_sda_I);
assign upstream2_sda_O=((upstream0_sda_T & upstream1_sda_T & upstream2_sda_T) ? downstream_sda_I : 1'b1) & (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I);
// slave device, upstream1_scl_T=1, upstream1_scl_I=1 即可
*/


assign downstream_scl_T = upstream0_scl_T & upstream1_scl_T & upstream2_scl_T & upstream3_scl_T;
assign downstream_scl_O = (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I) & (upstream2_scl_T ? 1'b1 : upstream2_scl_I) & (upstream3_scl_T ? 1'b1 : upstream3_scl_I);
assign downstream_sda_T = upstream0_sda_T & upstream1_sda_T & upstream2_sda_T & upstream3_sda_T;
assign downstream_sda_O = (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I) & (upstream2_sda_T ? 1'b1 : upstream2_sda_I) & (upstream3_sda_T ? 1'b1 : upstream3_sda_I);
assign upstream0_scl_O = downstream_scl_I;
assign upstream0_sda_O = downstream_sda_I;
assign upstream1_scl_O = downstream_scl_I;
assign upstream1_sda_O = downstream_sda_I;
assign upstream2_scl_O = downstream_scl_I;
assign upstream2_sda_O = downstream_sda_I;
assign upstream3_scl_O = downstream_scl_I;
assign upstream3_sda_O = downstream_sda_I;

endmodule


/*
I->|||<->IO
O<-|||


T==1, then left input, O=IO,I=X(don't care)
T==1, O<-IO

T==0, then left output, IO=I,O=X(don't care)
T==0, I->IO

IO=T?1:I
O=T?IO:1


Ta0->||||
Ia0->||||
Oa0<-||||Tb->
     ||||Ob->
Ta1->||||Ib-<
Ia1->||||
Oa1<-||||

slave device, Ta1_scl=1, Ia1_scl=1 即可

if(Ta0==0 && Ta1==1)从右上入，分发给左和右下，不关心右上出和左入
then Tb=0, Ob=Ia0,Oa1=Ia0,  Oa0=1(x),Ib=x
if(Ta0==1 && Ta1==0)从右下入，分发给左和右上，不关心右下出和左入
then Tb=0, Ob=Ia1,Oa0=Ia1,  Oa1=1(x),Ib=x
if(Ta0==1 && Ta1==1)从左输入，分发给右边每个，不关心左出右上入右下入
then Tb=1, Oa0=Ib,Oa1=Ib,   Ob=1(x),Ia0=x,Ia1=x


assign Tb = Ta0 & Ta1;
assign Ob = (Ta0 ? 1'b1 : Ia0) & (Ta1 ? 1'b1 : Ia1);
//assign Oa1 = Ib & Ia0;
assign Oa0 = (Tb?Ib:1'b1)&(Ta1?1'b1:Ia1) = ((Ta0 & Ta1)?Ib:1'b1)&(Ta1?1'b1:Ia1)
assign Oa1 = (Tb?Ib:1'b1)&(Ta0?1'b1:Ia0) = ((Ta0 & Ta1)?Ib:1'b1)&(Ta0?1'b1:Ia0)


推论 if(Ta0==0 && Ta1==0)
then Tb=0， Ob=Ia0&Ia1, Oa0=Ia1, Oa1=Ia0

assign downstream_scl_T = upstream0_scl_T & upstream1_scl_T;
assign downstream_scl_O = (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I);
assign upstream0_scl_O=((upstream0_scl_T & upstream1_scl_T) ? downstream_scl_I : 1'b1) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I);
assign upstream1_scl_O=((upstream0_scl_T & upstream1_scl_T) ? downstream_scl_I : 1'b1) & (upstream0_scl_T ? 1'b1 : upstream0_scl_I);

assign downstream_sda_T = upstream0_sda_T & upstream1_sda_T;
assign downstream_sda_O = (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I);
assign upstream0_sda_O=((upstream0_sda_T & upstream1_sda_T) ? downstream_sda_I : 1'b1) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I);
assign upstream1_sda_O=((upstream0_sda_T & upstream1_sda_T) ? downstream_sda_I : 1'b1) & (upstream0_sda_T ? 1'b1 : upstream0_sda_I);
*/


