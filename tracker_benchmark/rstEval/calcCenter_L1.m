function [r center] = calcCenter_L1(afnv, tsize)

rect= round(aff2image(afnv', tsize));
inp	= reshape(rect,2,4);

topleft_r = inp(1,1);
topleft_c = inp(2,1);
botleft_r = inp(1,2);
botleft_c = inp(2,2);
topright_r = inp(1,3);
topright_c = inp(2,3);
botright_r = inp(1,4);
botright_c = inp(2,4);

center=[(topleft_c + botright_c)/2, (topleft_r+botright_r)/2];

r = [topleft_c,topleft_r,botright_c-topleft_c+1,botright_r-topleft_r+1];
