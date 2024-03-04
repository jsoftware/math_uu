cocurrent 'z'

REPOCAL=: jpath '~Addons/math/cal'
REPOUU=:  jpath '~Addons/math/uu'

O=: '\'-.~ 0 :0
cal''  NB\. open cal.ijs
cai''  NB\. open cal_interface
uui''  NB\. open uu_interface
uuc''  NB\. open uuc
uuf''  NB\. open uuf
uut''  NB\. open uu lab
utf''  NB\. open uu test folder
)

cal=: 3 : 'open REPOCAL,''/cal.ijs'''
cai=: 3 : 'open REPOCAL,''/source/cal_interface.ijs'''
uui=: 3 : 'open REPOUU,''/source/uu_interface.ijs'''
uuc=: 3 : 'open TPUC sl ''/uuc.ijs'''
uuf=: 3 : 'open TPUF sl ''/uuf.ijs'''
uum=: 3 : 'open TPUM sl ''/uum.ijs'''
uut=: 3 : 'open TPUU sl ''/uu.ijt'''
uuu=: 3 : 'open TPUU sl ''/uu.ijs'''
utf=: 3 : 'openf REPOUU,''/test'''

test=: test_uu_
