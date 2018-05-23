program darvin;

uses crt, memory;

const
    str_sz=30;
    pop_sz=50;
    nCycles=100;
    maxFenotype=5.12;
    minFenotype=-5.12;
type
    chromosome_=record
      X:longint; {32 bits}
      Y:longint; {32 bits}
    end;
    fenotype_=record
      X:real;
      Y:real;
    end;
    individual=record
      chromosome:chromosome_;
      fenotype:fenotype_;
      Z:real;
    end;
    population_=array[0..pop_sz-1] of individual;
var
    oldPop, newPop, tmpPop:population_;

function random_:real;
begin
    random_:=random(65535)/(65535-1);
end;

function flip(probability:real):boolean;
begin
    if probability = 1.0 then
      flip := true
    else
      flip := (random_ <= probability);
end;

function pow(x: real; e:real):real;
begin
    pow:=exp(ln(x)*e);
end;

{always negative result!}
procedure decode(c:chromosome_; len:integer; var f:fenotype_);
begin
    f.X:=minFenotype+(maxFenotype-minFenotype)*(real(c.X)/(pow(2,len)-1));
    f.Y:=minFenotype+(maxFenotype-minFenotype)*(real(c.Y)/(pow(2,len)-1));
end;

function objfunc(f:fenotype_):real;
begin
    objfunc:=int(f.X)+int(f.Y);
end;

procedure randomBits(var dest:longint; len:integer);
var
    i:integer;
begin
	for i:=0 to len-1 do
	begin
		dest:=setbit(dest, i, flip(0.5));
	end;
end;

procedure generateChromosome(var c:chromosome_; len:integer);
begin
	randomBits(c.X, len);
	randomBits(c.Y, len);
end;

procedure initPopulation(var p:population_; popLen:integer; len:integer);
var
    i:integer;
begin
    for i:=0 to popLen-1 do
	begin
	    generateChromosome(oldPop[i].chromosome, len);
		decode(oldPop[i].chromosome, len, oldPop[i].fenotype);
		oldPop[i].Z:=objfunc(oldPop[i].fenotype);
	end;
end;

procedure computeIndividual(var i:individual; len:integer);
begin
  decode(i.chromosome, len, i.fenotype);
  i.Z:=objfunc(i.fenotype);
end;

procedure computePopulation(var p:population_; p_sz:integer; s_sz:integer);
var
  i:integer;
begin
  for i:=0 to p_sz-1 do
  begin
    computeIndividual(p[i], s_sz);
  end;
end;

procedure shuffle(var pop:population_; popLen:integer);
var
  i,j:integer;
  ind0:individual;
begin
  for i := popLen-1 downto 1 do begin
    j:= random(i-1);
    ind0:=pop[i];
    pop[i]:=pop[j];
    pop[j]:=ind0;
  end;
end;

procedure crossover(inA:chromosome_; inB:chromosome_; var outA:chromosome_; var outB:chromosome_; len:integer);
var
  template:chromosome_;
  i:integer;
begin
  generateChromosome(template, len);

  for i:=0 to len-1 do
  begin
    if isBit(template.X, i) then
	begin
	  outA.X:=setbit(outA.X, i, isBit(inA.X, len));
	  outB.X:=setbit(outB.X, i, isBit(inB.X, len));
	  outA.Y:=setbit(outA.Y, i, isBit(inA.Y, len));
	  outB.Y:=setbit(outB.Y, i, isBit(inB.Y, len));
	end
	else begin
	  outA.X:=setbit(outA.X, i, isBit(inB.X, len));
	  outB.X:=setbit(outB.X, i, isBit(inA.X, len));
	  outA.Y:=setbit(outA.Y, i, isBit(inB.Y, len));
	  outB.Y:=setbit(outB.Y, i, isBit(inA.Y, len));
	end;
  end;
end;

procedure crossoverPopulation(pIn:population_; var pOut:population_; popLen:integer; len:integer);
var
  i:integer;
begin
  for i:=0 to popLen-1 do
  begin
    if (i mod 2) = 0 then
	begin
	  crossover(pIn[i].chromosome, pIn[i+1].chromosome, pOut[i].chromosome, pOut[i+1].chromosome, len);
	end;
  end;
end;



{Z should be computed!!!}
procedure selectPopulation(var pIn:population_; var pOut:population_; popLen:integer; len:integer);
var
  i:integer;
  cnt:integer;
begin
  cnt:=0;
  for i:=0 to popLen-1 do
  begin
    if (i mod 2) = 0 then
	begin
	  if(pIn[i].Z<=pIn[i+1].Z) then
	    pOut[cnt]:=pIn[i]
	  else
	    pOut[cnt]:=pIn[i+1];
	  inc(cnt);
	end;
  end;
  shuffle(pIn, popLen);
  for i:=0 to popLen-1 do
  begin
    if (i mod 2) = 0 then
	begin
	  if(pIn[i].Z<=pIn[i+1].Z) then
	    pOut[cnt]:=pIn[i]
	  else
	    pOut[cnt]:=pIn[i+1];
	  inc(cnt);
	end;
  end;
end;

procedure mutate(var A:chromosome_; var B:chromosome_; p:real; len:integer);
var
  i:integer;
  first, second:integer;
  temp:chromosome_;
begin
  if(not flip(p)) then
    exit;
  first:=random(len);
  second:=first;
  while(second=first) do
    second:=random(len);
  temp:=A;
  A.X:=setbit(A.X, first, isbit(B.X, len));
  A.X:=setbit(A.X, second, isbit(B.X, len));
  B.X:=setbit(temp.X, first, isbit(temp.X, len));
  B.X:=setbit(temp.X, second, isbit(temp.X, len));
  A.Y:=setbit(A.Y, first, isbit(B.Y, len));
  A.Y:=setbit(A.Y, second, isbit(B.Y, len));
  B.Y:=setbit(temp.Y, first, isbit(temp.Y, len));
  B.Y:=setbit(temp.Y, second, isbit(temp.Y, len));
end;

procedure mutatePopulation(var pop:population_; popLen:integer; p:real; len:integer);
var
  i:integer;
begin
  for i:=0 to popLen-1 do
  begin
    if (i mod 2) = 0 then
	begin
	  mutate(pop[i].chromosome, pop[i+1].chromosome, p, len);
	end;
  end;
end;

function maxInPopulation(p:population_; popLen:integer):real;
var
  i:integer;
  r:real;
begin
  r:=p[0].Z;
  for i:=0 to popLen-1 do
  begin
    if(p[i].Z>r) then
	  r:=p[i].Z;
  end;
  maxInPopulation:=r;
end;
function minInPopulation(p:population_; popLen:integer):real;
var
  i:integer;
  r:real;
begin
  r:=p[0].Z;
  for i:=0 to pop_sz-1 do
  begin
    if(p[i].Z<r) then
	  r:=p[i].Z;
  end;
  minInPopulation:=r;
end;
function avgPopulation(p:population_; popLen:integer):real;
var
  i:integer;
  sum:real;
begin
  for i:=0 to pop_sz-1 do
  begin
    sum:=sum+p[i].Z;
  end;
  avgPopulation:=sum/real(popLen);
end;

var
zMin, zMax, zAvg: real;
ind_count, cycles_count:integer;
c:chromosome_;
f:fenotype_;
r:real;
BEGIN
  randomize;
  cycles_count:=0;
  initPopulation(oldPop, pop_sz, str_sz);
  computePopulation(oldPop, pop_sz, str_sz);
  zMin:=minInPopulation(oldPop, pop_sz);
  zMax:=maxInPopulation(oldPop, pop_sz);
  ind_count:=pop_sz;
  cycles_count:=1;
  zAvg:=avgPopulation(oldPop, pop_sz);
  
  while(cycles_count<nCycles) do
  begin
    selectPopulation(oldPop, tmpPop, pop_sz, str_sz);
	crossoverPopulation(tmpPop, newPop, pop_sz, str_sz);
	mutatePopulation(newPop, pop_sz, 0.3, str_sz);
	computePopulation(newPop, pop_sz, str_sz);
	if(minInPopulation(newPop, pop_sz)<zMin) then zMin:=minInPopulation(newPop, pop_sz);
	if(maxInPopulation(newPop, pop_sz)>zMax) then zMax:=maxInPopulation(newPop, pop_sz);
	ind_count:=ind_count+pop_sz;
	zAvg:=zAvg+avgPopulation(newPop, pop_sz);
	oldPop:=newPop;
	memset(addr(tmpPop), 0, sizeof(tmpPop));
	memset(addr(newPop), 0, sizeof(newPop));
    inc(cycles_count);
  end;
  
    writeln('zMin=',int(zMin));
	writeln('zMax=',int(zMax));
	writeln('zAvg=',zAvg/real(ind_count));
    readkey;
END.

