module sg90(input wire clk, output wire gripper, output wire upWrist, output wire downWrist, output wire armPlatform, 
output wire sparyingPlatform, output wire sparyingServoOne, output wire sparyingServoTwo,output wire trig ,input wire echo,output wire led);
reg [20:0] pf_reg, pulse_duration, pf_reg2,pulse_duration2;
reg gripper_bit, upWrist_bit, downWrist_bit, armPlatform_bit, sparyingPlatform_bit, sparyingServoOne_bit, sparyingServoTwo_bit;



//ULTraSonic
//output wire trig;
//output wire[2:0] led; // LED diode
//output wire[2:0] dan; // Pinovi za logički analizator
//input wire clk;
//input wire echo;
reg led_t= 1'b0;
reg trig_value = 1'b0;
reg [21:0] counterUltraSonic = 22'd0;
reg [18:0]echo_counter = 19'd0;
reg [19:0]delay_counter = 20'd0;

//ULTraSonic


assign gripper = gripper_bit;
assign upWrist = upWrist_bit;
assign downWrist = downWrist_bit;
assign armPlatform = armPlatform_bit;
assign sparyingPlatform = sparyingPlatform_bit;
assign sparyingServoOne = sparyingServoOne_bit;
assign sparyingServoTwo = sparyingServoTwo_bit;


task gripperMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   gripper_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;
end
endtask


task upWristMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   upWrist_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;

end
endtask

task downWristMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   downWrist_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;

end
endtask

task armPlatformMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   armPlatform_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;

end
endtask


task sparyingPlatformMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   sparyingPlatform_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;

end
endtask

task sparyingServoOneMove();
input reg [20:0] ugao;
begin
   pulse_duration=ugao;
   sparyingServoOne_bit <= (pf_reg < pulse_duration) ?1:0;
   pf_reg<=(pf_reg < 1000000)?(pf_reg+1):0;

end
endtask

task sparyingServoTwoMove();
input reg [20:0] ugao;
begin
   pulse_duration2=ugao;
   sparyingServoTwo_bit <= (pf_reg2 < pulse_duration2) ?1:0;
   pf_reg2<=(pf_reg2 < 1000000)?(pf_reg2+1):0;

end
endtask



reg [31:0] counter=32'd0;
reg [31:0] counterLimit=32'd1000000;
integer i=0;
reg [20:0] ugao=125000;
integer bool=0;
reg [5:0] state=6'd1;

task moveServo();
input reg [20:0] startUgao;
input reg [20:0] endUgao;
input reg [8:0] motor;
begin

reg [20:0] startPulse = 25000 + (555*startUgao);
reg [20:0] endPulse = 25000 + (555*endUgao);

if(bool==0)
begin
ugao=startPulse;
bool=1;
end

counter=counter+1;
if(counter>counterLimit)
begin

case(motor)
1:gripperMove(ugao);
2:upWristMove(ugao);
3:downWristMove(ugao);
4:armPlatformMove(ugao);
5:sparyingPlatformMove(ugao);
6:sparyingServoOneMove(ugao);
7:sparyingServoTwoMove(ugao);

endcase

end

if(counter>32'd2000000)
begin
counter = 0;
//Smanjuj ugao za jedan stepen=555 puls
if(startUgao>endUgao)
begin
ugao=ugao-555;
end
else
begin
ugao=ugao+555;
end

//Ako je puls manji od 25000 znaci da je ugao 0 limit je dostignut i ogranici ga

if(startUgao>endUgao)
begin

if(ugao<=endPulse)
begin
ugao=endPulse;
state = state+1;
bool=0;
end

end
else
begin

if(ugao>=endPulse)
begin
ugao=endPulse;
state = state+1;
bool=0;
end

end

end

end
endtask



reg [31:0] counterDelay = 0;
reg [31:0] counterDelayLimit = 100000000;
task delay();
begin
counterDelay = counterDelay + 1;

if(counterDelay>=counterDelayLimit)
begin
state = state + 1;
counterDelay=0;
end

end
endtask


reg [31:0] counterSpray = 0;
task sprayTask();
begin

counterSpray = counterSpray + 1;

//Kada prode 50ms uđi u ovaj if uslov, u suprotnom uđi u else
if(counterSpray>25000000 && counterSpray<=50000000)
begin
sparyingServoOneMove(75000);
sparyingServoTwoMove(75000);
end

else if(counterSpray>50000000)
begin
state= state+1;
counterSpray=0;
end

else
begin
sparyingServoOneMove(25000);
sparyingServoTwoMove(125000);
end

end
endtask



task ultraSonic();
begin
counterUltraSonic<=counterUltraSonic+1'b1;
if(counterUltraSonic<=500)
begin

trig_value <=1'b1;
end
else
begin
trig_value <= 1'b0;
if(echo && counterUltraSonic<700000)
begin
echo_counter<=echo_counter+1'b1;
if(echo_counter > 19'd294118 && echo_counter < 19'd300000)
//led_t <= 3'b111;
state = state+1;
//else if(echo_counter >= 19'd147059)
//led_t <= 3'b110;
else
led_t <= 3'b000;
end
else
if(echo_counter !== 19'd0)
begin
delay_counter <= delay_counter+1;
if(delay_counter >= 20'd100000000)
begin
counterUltraSonic <= 22'd0;
echo_counter <= 19'd0;
delay_counter <= 20'd0;
end
end
end
end

endtask



//1-Gripper, 2-upWrist, 3-downWrist, 4-armPlatform, 5-sprayingPlatform
//6-sprayingServoOne, 7-sprayingServoTwo


always @ (posedge clk)
begin


case(state)
1:ultraSonic();
2:moveServo(90,30,1); //Gripper se otvara
3:moveServo(90,150,2); //UpWrist se spusta
4:moveServo(30,120,1);  //Gripper se zatvara
5:moveServo(150,90,2);  //UpWrsit se podize
6:moveServo(90,0,4); //Platforma se rotira
7:moveServo(90,140,2); //upWrist se spusta
8:moveServo(120,90,1); //Gripper se otvara
9:moveServo(90,30,1);  //Gripper se otvara
10:moveServo(140,90,2); //upWrist se podize
11:delay(); //Delay
12:moveServo(90,0,5); //Okretanje platforme2
13:sprayTask(); //Dezinfekcija
14:sprayTask(); //Dezinfekcija
15:delay(); 
16:moveServo(0,90,5);//Okretanje platforme2
17:sprayTask();//Dezinfekcija
18:sprayTask();//Dezinfekcija
19:delay();
20:moveServo(90,180,5);//Okretanje platforme2
21:sprayTask();//Dezinfekcija
22:sprayTask();//Dezinfekcija
23:delay();
24:moveServo(180,90,5);//Okretanje platforme
25:sprayTask();//Dezinfekcija
26:sprayTask();//Dezinfekcija
27:delay();
28:moveServo(90,140,2);//Spustanje upWrist
29:moveServo(30,120,1);//Zatvaranje grippera
30:moveServo(140,90,2);//Podizanje upWrist
31:moveServo(0,90,4);//Okretanje platforme1
32:moveServo(90,140,2);//upWrist se spusta
33:moveServo(120,90,1);//Otvori gripper
34:moveServo(90,30,1);//Otvori gripper
35:moveServo(150,90,2);//Podizanje upWrist
36:moveServo(30,120,1);//Zatvarnje grippera
37:moveServo(120,90,1);//Zatvarnje grippera

endcase

end

assign led = led_t;
assign trig = trig_value;
endmodule