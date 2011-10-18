NB. UU: scientific units conversion package
coclass 'uu'
require 'strings dates'		NB. for: rplc, timestamp

NB. ========== NOUNS ==========

INVALID=: _.j_.
NOTE=: <;._1 ' C C# D D# E F F# G G# A A# B C'
NOTFOUND=: _1
NUN=: '??'
SL=: '/'
SP=: ' '
UNDEFINED=: _.	NB. should propagate in a formula
mks=: ;:'m kg s A K cd mol rad eur'  NB. primitive SI-units
SIG=: 3
UNICODE=: 1
MAXLOOP=: 30
SAVEPATH=: '~user/tabula'
UCASE=: 0	NB. =:1 for case-insensitive ssmx
sess=: empty
sess_umake=: empty
CUTAB0=: 2 2$<;._1 ' USD 1.3 GBP 0.8'	NB. dummy short table
CUTAB=: CUTAB0				NB. pre-start value


NB. ========== PREREQS ==========

any=: +./
brack=:	1 |. '][' , ":	NB. layout tool for message string ->'[y]'
cmx=: [: > <;._2	NB. expects trailing LF
nb=: [: ([: }. [: ; ' ' ,&.> ]) ":&.>	NB. embed nums in string
or=:  +.
not=: -.
to=:    [ + [: i. [: >: -~	NB. eg: 3 to 5 <--> 3 4 5

cx=: 3 : 0
	NB. check for complex nouns in given locale
loc=. >coname''
nocomplex=. 1
for_no. (nl 0) -. <'INVALID' do.  val=. ".nom=. >no
  if. 16=3!:0 val do.
    smoutput nb 'cx:' ; nom ; 'is complex'
    nocomplex=. 0
  end.
end.
NB. Suppress ok-confirmation...
NB. if. nocomplex do. smoutput 'cx: no nouns are complex in: ',loc end.
i.0 0
)

undefined=: (3 : 0)"0
	NB. test for presence of UNDEFINED
if. -. 128!:5 y do. 0 return. end.
'_.' -: 5!:6 <'y'
)

invalid=: (3 : 0)"0
	NB. test for presence of INVALID
if. -. 128!:5 y do. 0 return. end.
'_.j_.' -: 5!:6 <'y'
)

quoted=: 3 : 0
	NB. =1 iff (y) is a quoted currency
(<toupper y) e. {."1 CUTAB
)



NB. ========== ADVERBS ==========

NB. ========== CONJUNCTIONS ==========

NB. ========== VERBS ==========

adj=: 4 : 0
	NB. adjust numeral y for units: x
	NB. cases prefixed '_' are inverse adjustments used by: setvalue
select. x
case. 'deg.C'	do.	z=. y-273.16
case.'_deg.C'	do.	z=. y+273.16
case. 'Celsius'	do.	z=. y-273.16
case.'_Celsius'	do.	z=. y+273.16
case. 'deg.F'	do.	z=. y-459.688
case.'_deg.F'	do.	z=. y+459.688
case. 'Fahrenheit'	do.	z=. y-459.688
case.'_Fahrenheit'	do.	z=. y+459.688
case.		do.     z=. y	NB. default adjustment (none)
end.
)

canc=: 4 : 0
	NB. cancel-out
	NB. serves: canon
	NB. eg: ' m kg kg/kg/kg s/s' canc 'kg'
z=. ,x		NB. the object string
n=. SP,y	NB. unit: y in numerator
d=. SL,y	NB. unit: y in denominator
whilst. -. w-:z do.
  z=. (w=.z) rplc (n,d);'' ; (d,n);''
end.
)

canon=: 3 : 0
	NB. Sort units (str y) into canonical order
	NB. y must be fully-resolved units, ie all from boxed list: mks
	NB. Sort boxed tokens ignoring SP|SL. This brings num+denom terms together
z=. ; |. each sort |. each utoks y
	sess nb 'canon:' ; TAB ; 'z=' ; z
	NB. Cancel-out/collect each unit from global boxed list: mks in turn...
for_w. mks do. m=. ,>w		NB. m== next unit from list: mks
  if. +./ m E. z do.		NB. only if m is present in z
    z=. (z canc m) coll m
	sess nb 'canon:' ; TAB ; (brack m) ; 'z=' ; z
  end.
end.
z=. debnSL dlb ; sort utoks z	NB. k-m-s order, with denominators gathered behind
if. 0=#z do. z=. ,SL end.  	NB. CONVENTION: (empty z) --> ,'/'
)

cnvf=: 3 : 0
	NB. expand y using units->unitv, also return the conversion factor f
z=. (f=. INVALID) ; '' ; NOTFOUND	NB. "not-found" returned value
t=. utoks cnvv y			NB. y is a bare (units), no SP|SL
if. LK=NOTFOUND do. z return. end.
try. z=. (f=.LK{uvalu); t; LK		NB. item-value from LK: UU-row found by: cnvv
catch.
end.
	sess nb 'cnvf:' ; TAB ; 'f=' ; f ; (linz t)
z
)

cnvi=: 4 : 0
	NB. invert SP <--> SL throughout token-list iff (Bool)x
if. x do.
  for_i. i.#y do.
    z=. >i{y
    if. SL={.z do.
      z=. SP,(}.z)
    elseif. SP={.z do.
      z=. SL,(}.z)
    end.
    y=. (<z) i}y
  end.
end.
y
)

cnvj=: 3 : 0
	NB. cut prefs/suffs from a cunit (eg: '/kg^3')
k=. p=. 1 [ z=. y
if. j=.(SL={. sp1 z) do. z=. }.z end.	NB. bool:j remembers dropped prefix: SP|SL
if. '^' e. z do.			NB. recognise a power...
  'p z'=. (".{:z) ; (}:}:z)		NB. drop/remember suffixed power (as integer)
end.
	NB. Identify scaling prefixes, eg 'ms', 'Gs' -variants of: s
	NB. ONLY IF z is not itself in: units, eg 'knot' ...
if. (iskg z) or (not validunits z) do.
	NB. Identify a 2-CHAR scaling prefix ...
  if. 	  'da'-:2{.z do.	k=. 1e1		[ z=.2}.z	NB. deka-
  elseif. 'mu'-:2{.z do.	k=. 1e_6	[ z=.2}.z	NB. micro-
  elseif. do.
	NB. Identify a 1-CHAR scaling prefix ...
    select. {.z
     case. 'h' do. k=. 1e2	[ z=.}.z	NB. hecto-
     case. 'k' do. k=. 1e3	[ z=.}.z	NB. kilo-
     case. 'M' do. k=. 1e6	[ z=.}.z	NB. mega-
     case. 'G' do. k=. 1e9	[ z=.}.z	NB. giga-
     case. 'T' do. k=. 1e12	[ z=.}.z	NB. tera-
     case. 'P' do. k=. 1e15	[ z=.}.z	NB. peta-
     case. 'E' do. k=. 1e18	[ z=.}.z	NB. exa-
     case. 'Z' do. k=. 1e21	[ z=.}.z	NB. zetta-
     case. 'Y' do. k=. 1e24	[ z=.}.z	NB. yotta-
     case. 'd' do. k=. 1e_1	[ z=.}.z	NB. deci-
     case. 'c' do. k=. 1e_2	[ z=.}.z	NB. centi-
     case. 'm' do. k=. 1e_3	[ z=.}.z	NB. milli-
     case. 'u' do. k=. 1e_6	[ z=.}.z	NB. micro- (alternative to: mu)
     case. 'n' do. k=. 1e_9	[ z=.}.z	NB. nano-
     case. 'p' do. k=. 1e_12	[ z=.}.z	NB. pico-
     case. 'f' do. k=. 1e_15	[ z=.}.z	NB. femto-
     case. 'a' do. k=. 1e_18	[ z=.}.z	NB. atto-
     case. 'z' do. k=. 1e_21	[ z=.}.z	NB. zepto-
     case. 'y' do. k=. 1e_24	[ z=.}.z	NB. yocto-
    end.
  end.
end.
z=. deb z
  NB. Scaling prefixes recognised above:
  NB.	------------------------------------------------------------------------------
  NB. 	deca- 	hecto- 	kilo- 	mega- 	giga- 	tera- 	peta- 	exa- 	zetta- 	yotta-
  NB. 	da 	h 	k 	M 	G 	T 	P 	E 	Z 	Y
  NB. 	10^1 	10^2 	10^3 	10^6 	10^9 	10^12 	10^15 	10^18 	10^21 	10^24
  NB.	------------------------------------------------------------------------------
  NB. 	deci- 	centi- 	milli- 	micro- 	nano- 	pico- 	femto- 	atto- 	zepto- 	yocto-
  NB. 	d 	c 	m 	µ 	n 	p 	f 	a 	z 	y
  NB. 	10^−1 	10^−2 	10^−3 	10^−6 	10^−9 	10^−12 	10^−15 	10^−18 	10^−21 	10^−24
  NB.	------------------------------------------------------------------------------
 sess nb 'cnvj:' ; TAB ; '/-?' ; j ; 'scale(k)=' ; k ; 'units(z)=' ; z ; 'power(p)=' ; p
j ; k ; z ; p		NB. here z has NO prefixed SP (or SL)
)

cnvnon=: 3 : 0
	NB. extract 1st non-mks token
i=. (y e. mkss)i. 0	NB. index of 1st token not in mkss
if. i<#y do.
  t=. >i{y		NB. the extracted token
  y=. (i~: i.#y)# y	NB. the residue without t
else.
  t=. ''		NB. and y is unchanged
end.
 sess nb 'cnvnon:' ; TAB ; 'next non-mks token=' ; (brack t) ; 'leaving:' ; (linz y)
(deb t) ; <y
)

cnvv=: 3 : 0
unitv cnvv y
:
	NB. the x-(unitv/x) entry corresp to units: y
	NB. SETS GLOBAL CACHED LOOKUP INDEX: LK <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
LKS=: ,LK=: NOTFOUND	NB. init to: "not-found" value
if. 0=#z=. I.units=(<,y) do. '' return. end.
LK=: {.LKS=: z
>LK{x		NB. Only the first match is returned
)

cnvx=: 3 : 'unitx cnvv y'

coll=: 4 : 0
	NB. collects-terms (no cancel-out)
	NB. serves: canon
	NB. eg: ' m kg kg/kg/kg s/s' coll 'kg'
	NB.	 m kg^2/kg^2 s/s
P=. '^'
z=. ,x			NB. the object string
n=. SP,y		NB. unit: y in numerator
d=. SL,y		NB. unit: y in denominator
for_p. 4 3 2 do.	NB. 4th-power units are highest recognised
  z=. z rplc ((p*$n)$n);(n,P,":p) ; ((p*$d)$d);(d,P,":p)
  sess nb 'coll:' ; TAB ; 'z=' ; z ; 'j=' ; j
end.
z
)

compatible=: 4 : 0
	NB. =1 iff units x,y compatible
	NB. '*' is compatible with everything...
if. ('*'= {.>x) +. ('*'= {.>y) do. 1 return. end.
ux=. compat cnvv >x [ uy=. compat cnvv >y
	sess nb 'compatible:'; 'ux='; ux; 'uy='; uy
if. (0<#uy) *. (uy-:ux) do. 1 return. end.
a=. {.convert >x [ b=. {.convert >y
a-:b	NB. match their canonical units
)

compatlist=: 3 : 0
	NB. return extract of (units) compatible with units: y
z=. ''
y_uu_=: y
	NB. if there's a compat-code (uy), get its mates
	NB. else lookup its cfm in: unitx
if. 0<#uy=. compat cnvv >y do.
  z=. (I. uy=compat){units
else.
  cn=. {.convert y
  z=. (I. cn=unitx){units
end.
z=. ~. (<,y),z,{.convert y	NB. incl uy itself and its canon
)

convert=: 3 : 0
1 convert y	NB. x=1 --use: uvalx
:
	NB. y(units) --> cu ; loop_count ; cf
	NB. Converts arbitrary compound units (str) to primitive SI-units as defined in: mks
	NB. Needed to compare two arbitrary units to see if compatible / inter-convertible.
	NB. Simplifies the result of a division of 2 physical quantities.
	NB. Returns 3-element: z
	NB.  (>{.z) is the canonical units (cu)
	NB.  (>{:z) is conversion factor (cf)
	NB.  (>1{z) is diagnostic only: the number of lookup-cycles.
	NB. Returns a canonical form (defined by: canon) to allow comparison using (-:).
	NB.  DEFN cunit: a canonical element, having prefix, scale and power, eg '/s^2'
	NB. Has a set of service-fns with names all cnv*:
	NB.  cnvnon z	extract 1st non-mks cunit(, returns: cunit;residue
	NB.  cnvj t	cut t into: (1_if_prefixed_SL ; 10^n_scale ; unit ; ^n_repetition)
	NB.  cnvf t	lookup t in: units-->unitv, returns (factor ; units)
	NB. 		-if not found, factor is _. -test using: isNaN f
	NB.  cnvv t	called by: cnvf
	NB.  j cnvi t	converts all SP<-->SL in cunits-str: t iff j=1
	NB. 		- (j=1 iff the cunit of which t is the expansion had prefix SL
	NB. Uses: cnvnon to find first non-mks unit, t, 0=$t if no more units remaining.
	NB. A units str consists of a series of tokens called "cunits", order immaterial.
	NB. A cunit may be prefixed by SL (/) denoting denominator or by SP denoting numerator.
	NB. Fn: utoks tokenises a units str. ensures 1st cunit has a leading SP
	NB.  provided a leading SL is not already present. Uses sp1 to achieve this.
	NB. Since SP is a meaningful cunit prefix, use of: deb will expunge not only SP,SP
	NB.  but also any leading SP. But there must be a leading SP|SL.
	NB. Uses: cnvf to lookup (bare) unit in: units-->unitv
	NB. The expanded units tokens are then SUFFIXED to the unprocessed residue: rx
	NB. -we can do that since order of cunits is immaterial.
	NB. Fn: cnvf also returns conversion factor (f)
	NB. Finally when no more units to expand (max cycles=30 as failsafe)
	NB. the result is converted to canonical form using: canon.
if. x do.	NB. SPEEDUP: try: unitx, uvalx (if there)
  if. 0<#z=.cnvx y do. (z ; 1 ; LK{uvalx) return. end.
end.
fac=. 1				NB. conversion factor init'd
z=. utoks y			NB. needs y tokenised
 sess nb 'convert:' ; 'utoks=' ; z
	NB. Comb repeatedly through tokenized (boxed) z, converting tokens by lookup in UUC,
	NB. each converted token (expanded) is appended to back of z, to be combed again,
	NB. Repeat until all tokens in z are mks (=metre-kilogram-second)
for_i. i.MAXLOOP do.
  loop=. i+1			NB. loop-count available on drop-thru
  't rz'=. cnvnon z		NB. extract 1st non-mks token: t leaving residue: rz
  if. 0=#t do. break. end.	NB. quit loop if all are mks tokens
  if. t-:,'*' do. ('*' ; loop ; 1) return. end.	NB. '*' factor always 1
  'j k tt p'=. cnvj t		NB. separate: t -eg: '/ms^2' --> 1;0.001;'s';2
  'f ttt lk'=. cnvf tt		NB. lookup tt in UUC --> factor(f) ; new_tt(ttt) ; UUC_line#(lk)
  if. (isNaN f)+.(lk=_1) do. (NUN ; loop ; _) return. end.	NB. SIGNALS FAILURE !!
  subfac=. (f*k)^p
	NB. accumulate subfac into fac, according to whether j specifies numerator/denominator
  fac=. fac * subfac^(np j)
  z=. rz,p#(j cnvi ttt)		NB. put back into z: p-replicated (inverted) ttt
	sess nb 'convert:';(brack loop); 'z=';(linz z); 'fac=';fac; 'j=';j; 'subfac=';subfac
end.
	NB. if MAXLOOP reached then must assume not all non-mks tokens have been converted
if. loop=MAXLOOP do. loop=. 0 end. NB. signalling a suspicious result
(canon ;z) ; loop ; fac
)

curfig=: 3 : 'hy (0 j. 2)":y'
debSL=: #~ (+. (1: |. (> </\)))@('/'&~:)

debnSL=: 3 : 0
	NB. remove SL repetitions preserving (any) leading SL
	NB. serves: canon
if. SL={.y do. SL,debSL }.y
else. debSL y
end.
)

degreeformat=: 3 : 0
	NB. output y as: '360deg 0amin 30asec'
	NB. ucode -converts this to the usual symbols
if. y-:'' do. y=. undeg 360 0 30 end.	NB. TEST <<<<<
neg=. (y<0)#'-'
NB. suf=. '° ' ; ''' ' ; '"'
suf=. 'deg ' ; 'amin ' ; 'asec'
z=._ 60 60 #: 3600*|y
z=. ": each <. z
neg , ; z ,each suf
)

eval=: 3 : 0
	NB. used to evaluate numeric exprns in UUC
y=. '/%'charsub ;y
try. {.".y catch. INVALID end.
)

exrate=: exrate_exch_

format=: 3 : 0
'' format y
:
	NB. format numeral y by units: x
	NB. always returns a string
if. undefined y do. 'UNDEFINED' return.
elseif. invalid y do. 'INVALID' return.
end.
y=. x adj y	NB. adjust y-value if needed by x
select. ,x
	NB. INSERT FURTHER fcase.s HERE for unicoded suffix
 case. 'asec'	do. z=. '"' upost sigformat y
 case. 'amin'	do. z=. '''' upost sigformat y
fcase. 'Fahrenheit'	do.
fcase. 'deg.F'	do.
fcase. 'Celsius'	do.
 case. 'deg.C'	do. z=. 'deg' upost sigformat y
 case. 'deg'	do. z=. degreeformat y	NB. (deg amin asec)
 case. 'usd'	do. z=. '$',curfig y
fcase. 'gbp'	do.
 case. 'eur'	do. z=. x upref curfig y  NB. 2 sig figures
 case. ,'!'	do. z=. >(y=0){'YES';'NO'
 case. 'midi'	do. z=.": rnd midino y	NB. MIDI-number
 case. 'note'	do. z=. note midino y	NB. musical note
	NB. INSERT FURTHER fcase.s HERE for sci-notation
fcase. ,'c'	do.	NB. lightspeed
fcase. 'eV'	do.	NB. electron-volt
fcase. 'Hz'	do.	NB. frequency: Hertz
 case. 'rad'	do. z=. sciformat y
	NB. INSERT FURTHER fcase.s HERE for SIG controlled
fcase. ,'/'	do.	NB. dimensionless
 case. ,'*'	do. z=. sigformat y
	NB. ALL ELSE...
 case.		do. z=. sigformat y
end.
ucode z
)

generalformat=: toupper@hy@":
hy=: '_-' charsub ]
isNaN=: 128!:5

iskg=: 3 : 0
	NB. =1 iff units y is 'kg' or begins with: 'kg'
	NB. and is scalable by altering prefix
if. y-:'kg' do. 1 return. end.
if. not 'kg' -: 2{.y do. 0 return. end.
	NB. Further test(s) if z starts with: 'kg'
if. any 'kg^' E. y do. 0 return. end.	NB. cannot accept powers of [kg]
1	NB. accept with no more tests
)

linz=: 3 : 0
	NB. linearize a boxed string of tokens for smoutput
z=. }: ; (>y) ,. '|'
brack z -. SP
)

midino=: 3 : '69 + 12* 2 ^. y % 440'

note=: 3 : 0
	NB. musical note nearest to MIDI no: y
,>NOTE {~ rnd 12 | y
NB. smoutput note midino 440	NB. A
NB. smoutput note midino 194.18	NB. G (the earth-rotation freq)
)

np=: [: <: 2 * -.
rnd=: [: <. 0.5 + ]
sciformat=: toupper@hy@":
set_ucase=: 3 : 'UCASE=: y'
set_unicode=: 3 : 'UNICODE=: y'

setsig=: 3 : 0
	NB. set SIG (decimal places for: sigformat)
SIG=: ". ": y
)

sigformat=: 3 : 'hy (0 j. SIG)":y'

sp1=: 3 : 0
	NB. ensure ONE leading SP iff there is no SL
y=. deb y
if. SL~:{.y do. y=. SP,y end.
)

ssmx=: 4 : 'if. UCASE do. x ssmxU y else. x ssmxM y end.'
ssmxM=: 4 : 'I. * +/"(1) y ss"1 x'
ssmxU=: 4 : '(toupper x)ssmxM toupper y'

start=: 3 : 0
load '~addons/math/uu/uuc.ijs'
load '~addons/math/uu/uuf.ijs'
umake''
)

test=: 3 : 0
	NB. inspect result of: umake
if. y=_ do. 0 test _	NB. to output the whole table
else. y test y		NB. just a single line
end.
:
	NB. test of UUC against umake globals
	NB. Eg:	  test _	NB. whole table
	NB.	5 test 7	NB. lines 5-7 
smoutput 'i compat units uvalu  unitv uvalx unitx (>>) \\ i{UUC'
for_i. x to (y <. <:#UUC) do.
if. i=i{compat do.
  z=. ''			NB. warning flag (=ok)
else.
  v=. (i{compat) {uvalu		NB. the senior's ratio
  if. v=1 do. z=. '' else. z=. '>>',": v end.
end.
smoutput nb i; (i{compat); (brack >i{units); (i{uvalu); (>i{unitv); (>i{uvalx); (>i{unitx); z ; '\\' ; (i{UUC)
end.
)

testf=: 3 : 0
if. 0=#y do. y=. 123.4567 end.
	NB. test: format (and friends)
for_no. ;:'eur gbp usd deg ! c eV Hz rad / *' do.
	nom=. ,>no
	smoutput nb nom ; TAB ; nom format y
end.
)

ucode=: 3 : 0
	NB. subst (x=1) symbol for PI etc and back again (x=0)
1 ucode y	NB. forces (wchar) by default (x=1)
:
if. -.UNICODE do. y return. end.
if. x do. 7 u: y rplc ,cspel,.csymb
else. y rplc ,csymb,.cspel
end.
)

ucods=: 3 : 0
	NB. subst (x=1) symbol for PI etc and back again (x=0)
	NB. c/f ucode, but this version ignores currency symbols
1 ucods y	NB. forces (wchar) by default (x=1)
:
if. -.UNICODE do. y return. end.
if. x do. 7 u: y rplc ,sspel,.ssymb
else. y rplc ,ssymb,.sspel
end.
)

udat=: 4 : 0
	NB. raw boxed data from y=. seltext''
  NB. x=0 -const
  NB. x=1 -formula
'y zdesc'=. ']'cut y
zdesc=. dltb zdesc -.TAB
'y znits'=. '['cut y
NB. 'z y'=. '}'cut y	NB. WITHDRAWN: leading {**}
if. x do.		NB. return fields for a formula
  zfmla=. deb y-.TAB
  zdesc; znits; zfmla
else.
zvalu=. (i=. y i. SP){.y=. deb y-.TAB
znitv=. }.i}.y
  zdesc; znits; znitv; zvalu
end.
)

udiv=: 4 : 0
	NB. divide 2 generalized units-strs: x y
	NB. For use by (eg): combine in: cal
	NB. The simple result: x,SL,y is ok unless y is a complex of units
	NB. in which case y must be tokenised and inverted piecemeal.
if. +./ (SP,SL) e. y do.
  z=. 1 cnvi utoks y	NB. invert tokenised y
  x , ;z		NB. combine x, z as if multiplied.
else.
  x,SL,y		NB. the simple solution
end.
)

udumb=: 3 : 0
'zdesc znits znitv zvalu'=. y
zdesc; znits; 1		NB. assume 1 nominal unit is only ever required
)

umake=: 3 : 0
0 umake y	NB. x=0: DONT adjust currency
:
	NB. make globals: cspel csymb mks mkss units unitv uvalu unitx uvalx compat
	NB. (cspel csymb) -used by: ucode to convert units: unicode<-->ascii
	NB. (sspel ssymb_ -used by: ucods (ditto, omits currency symbols)
sess_umake 'umake: enters...'
sspel=: <;._1 ' PI mu Ang Ohm ^2 ^3'
ssymb=: <;._1 '|π|µ|Å|Ω|²|³'
	NB. cspel,csymb converts these also...
cspel=: sspel, <;._1 ' deg amin asec eur cnt gbp'
csymb=: ssymb, <;._1 '|°|''|"|€|¢|£'
	NB. mks (c/f 'm kg s') specifies the most primitive SI-units
	NB. mkss is used by: cnvnon<--convert to identify reducible units
NB. mks=: ;:'m kg s A K cd mol rad eur' NB. <<<set in ONLOAD
mkss=: (SP,each mks),(SL,each mks),<,SL
units=: unitv=: uvalu=: 0$0
for_i. iu=.i.#UUC do.
  'zdesc znits znitv zvalu'=. 0 udat i{UUC
  if. x *. quoted znits do.
    sess_umake i ; znits ; zvalu ; '=:' ; %exrate znits
    zvalu=. ": %exrate znits
  end.
  units=: units,<,znits		NB. nominal units
  unitv=: unitv,<,znitv		NB. based-on units
  uvalu=: uvalu,eval zvalu	NB. conversion ratio as given
end.
z=. |: > 0 convert each units
unitx=: 0{z	NB. canonical units
cycs=. ;1{z	NB. diagnostic: loops needed by: convert
uvalx=: ;2{z	NB. conversion ratio to canonical units
compat=: unitx i. unitx		NB. compat-code: > earlier UUC-row#
	NB. z is boolean mask for: (units)
z=. cycs=0
z=. z+.(isNaN uvalu)+.(uvalu e. 0 _ __)
z=. z+.(isNaN uvalx)+.(uvalx e. 0 _ __)
if. +./ z do.
  t=. ;,((I.z){units) ,. (brack each I.z),.<' '
  msg=. '>>> WARNING: these units convert badly:',LF,t
  wd 'mb TABULA_UU ',dquote msg
end.
cx''	NB. check if any noun has become complex
sess_umake 'umake: ...exits'
i.0 0
)

undeg=: 3600 %~ _ 60 60 #. 3 {. ]
upost=: 4 : 'y,(UNICODE#x)'
upref=: 4 : '(UNICODE#x),y'

utab=: 3 : 0
	NB. TEST diagnostics table of caches
smoutput nb 'units' ;TAB; 'uvalu' ;TAB; 'uvalx'
if. 0=#y do. y=. i.#units end.
for_i. y do.
  smoutput nb i ; (brack >i{units) ;TAB; (iu=.i{uvalu) ;TAB; (ix=.i{uvalx)
  if.-. iu=ix do.
    smoutput TAB,'>>> uvalu not equal to uvalx'
  end.
end.
)

utoks=: 3 : 0
	NB. tokenize y, ensuring leading SP|SL
z=. sp1 y	NB. ensure leading sign-byte: SP|SL
z=. (z e. SP,SL) <;.1 z
)

uu=: 3 : 0
	NB. transform y (value;units) to: x (ux)
'' uu y
:
	NB. x is target units: ux
	NB. y is value;units
select. datatype y
case. 'literal' do.
  value=. ". ' 'taketo y
  units=. ' 'takeafter y
case. 'boxed' do.
  'value units'=. y
case. do.
  '>>> cannot handle:' ; y
  return.
end. 
ux=. x
if. 0~:#x do.
  if. -. x compatible units do.
    0 ; nb '>>> incompatible units:' ; x ; units
    return.
  end.
end.
'uy c fy'=. convert units
'ux c fx'=. convert x
z=. (value adj~ '_',units) * fy
z=. (z adj~ x) % fx
if. 0=#x do. z ; uy
else. z ; x
end.
)

uurowsc=: 3 : '(UUC ssmx y){UUC'
uurowsf=: 3 : '(UUF ssmx y){UUF'
validunits=: 3 : 'units e.~ <,y'

uu_z_=: uu_uu_
start ''
