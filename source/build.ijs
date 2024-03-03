NB. math_uu repo - build

cocurrent 'base'

NB.==================================
GIT=. '~Addons/math/uu'  NB. for JAL release
NB.==================================

NB. TO LOAD JUST THIS BUILTFILE:	fn⌘F9
NB. DITTO THEN RUN:		fnF9

smoutput '--- Build: started for: ',GIT

date_z_=: 6!:0 bind 'YYYY-MM-DD  hh:mm:ss'

NOW=: date''
BUILTFILE_z_=: GIT,'/uu.ijs'

NB. build BUILTFILE
dat=. readsourcex_jp_ (GIT,'/source')
dat=. dat rplc 'BUILTAT';'AABUILT=: ',quote NOW
dat fwrites BUILTFILE

smoutput '--- Build: completed for: ',GIT
