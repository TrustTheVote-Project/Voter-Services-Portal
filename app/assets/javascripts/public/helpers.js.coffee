window.filled = (v) -> v && !v.match(/^\s*$/)
window.join   = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)
window.zip5   = (v) -> filled(v) && v.match(/^\d{5}$/)
window.ssn    = (v) -> filled(v) && v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){9}$/)
window.date   = (y, m, d) -> filled(y) && filled(m) && filled(d) && moment([y, m, d]).diff(new Date()) < 0
window.phone  = (v) -> v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){10}$/)
window.email  = (v) -> v.match(/^\S+@\S+\.\S+$/)
window.voterId= (v) -> v.replace(/[^\d]/, '').match(/^\d{16}$/)
