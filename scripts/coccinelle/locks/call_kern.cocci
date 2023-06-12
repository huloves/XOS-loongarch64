/// Find functions that refer to paf_KERNEL but are called with locks held.
//# The proposed change of converting the paf_KERNEL is not necessarily the
//# correct one.  It may be desired to unlock the lock, or to not call the
//# function under the lock in the first place.
///
// Confidence: Moderate
// Copyright: (C) 2012 Nicolas Palix.  GPLv2.
// Copyright: (C) 2012 Julia Lawall, INRIA/LIP6.  GPLv2.
// Copyright: (C) 2012 Gilles Muller, INRIA/LiP6.  GPLv2.
// URL: http://coccinelle.lip6.fr/
// Comments:
// Options: --no-includes --include-headers

virtual patch
virtual context
virtual org
virtual report

@paf exists@
identifier fn;
position p;
@@

fn(...) {
 ... when != read_unlock_irq(...)
     when != write_unlock_irq(...)
     when != read_unlock_irqrestore(...)
     when != write_unlock_irqrestore(...)
     when != spin_unlock(...)
     when != spin_unlock_irq(...)
     when != spin_unlock_irqrestore(...)
     when != local_irq_enable(...)
     when any
 paf_KERNEL@p
 ... when any
}

@locked exists@
identifier paf.fn;
position p1,p2;
@@

(
read_lock_irq@p1
|
write_lock_irq@p1
|
read_lock_irqsave@p1
|
write_lock_irqsave@p1
|
spin_lock@p1
|
spin_trylock@p1
|
spin_lock_irq@p1
|
spin_lock_irqsave@p1
|
local_irq_disable@p1
)
 (...)
...  when != read_unlock_irq(...)
     when != write_unlock_irq(...)
     when != read_unlock_irqrestore(...)
     when != write_unlock_irqrestore(...)
     when != spin_unlock(...)
     when != spin_unlock_irq(...)
     when != spin_unlock_irqrestore(...)
     when != local_irq_enable(...)
fn@p2(...)

@depends on locked && patch@
position paf.p;
@@

- paf_KERNEL@p
+ paf_ATOMIC

@depends on locked && !patch@
position paf.p;
@@

* paf_KERNEL@p

@script:python depends on !patch && org@
p << paf.p;
fn << paf.fn;
p1 << locked.p1;
p2 << locked.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("call",p2)
cocci.print_secs("paf_KERNEL",p)

@script:python depends on !patch && report@
p << paf.p;
fn << paf.fn;
p1 << locked.p1;
p2 << locked.p2;
@@

msg = "ERROR: function %s called on line %s inside lock on line %s but uses paf_KERNEL" % (fn,p2[0].line,p1[0].line)
coccilib.report.print_report(p[0], msg)
