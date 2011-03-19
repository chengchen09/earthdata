
FIGS =  spatial-loc.eps spatial-loc-cdf.eps suffix-loc.eps suffix-loc-pdf.eps suffix-loc-dir.eps depth-loc.eps depth-loc-pdf.eps interval-file-pdf.eps interval-file-cdf.eps interval-dir-pdf.eps interval-dir-cdf.eps depth-freq-corp-xy.eps depth-freq-engi-xy.eps freq-file-pdf.eps freq-dir-pdf.eps freq-file-cdf.eps freq-dir-cdf.eps freq-inter-file-corp.eps freq-inter-file-engi.eps freq-inter-dir-corp.eps freq-inter-dir-engi.eps

# DATADIR = /home/meta/workdata-chen


all:


fig: $(FIGS)

fig-install: $(FIGS)
	cp -rf $^ ../paper/fig/

spatial-loc.eps: spatial-loc.plot ../data/locality-corp.txt ../data/locality-engi.txt
	gnuplot spatial-loc.plot

spatial-loc-cdf.eps: spatial-loc-cdf.plot ../data/locality-corp.txt ../data/locality-engi.txt
	gnuplot spatial-loc-cdf.plot

suffix-loc.eps: suffix-loc.plot suffix-loc.pl ../data/suffix-corp.txt ../data/suffix-engi.txt
	gnuplot suffix-loc.plot

suffix-loc-pdf.eps: suffix-loc-pdf.plot suffix-loc.pl ../data/suffix-corp.txt ../data/suffix-engi.txt
	gnuplot suffix-loc-pdf.plot

suffix-loc-dir.eps: suffix-loc-dir.plot ../data/suffix-dir-corp-pdf.txt ../data/suffix-dir-engi-pdf.txt
	gnuplot suffix-loc-dir.plot

depth-loc-pdf.eps: depth-loc-pdf.plot ../data/depth-corp.txt ../data/depth-engi.txt
	gnuplot depth-loc-pdf.plot

depth-loc.eps: depth-loc.plot ../data/depth-corp.txt ../data/depth-engi.txt
	gnuplot depth-loc.plot	

depth-freq-engi-xy.eps: depth-freq.plot depth-freq.pl ../data/freq-file-engi.gz
	gnuplot depth-freq.plot

depth-freq-corp-xy.eps: depth-freq.plot depth-freq.pl ../data/freq-file-corp.gz
	gnuplot depth-freq.plot

freq-file-pdf.eps: freq-file-pdf.R ../data/freq-file-corp.gz ../data/freq-file-engi.gz
	./freq-file-pdf.R

freq-dir-pdf.eps: freq-dir-pdf.R ../data/freq-dir-corp.gz ../data/freq-dir-engi.gz
	./freq-dir-pdf.R

freq-file-cdf.eps: freq-file-cdf.plot ../data/freq-file-corp.gz ../data/freq-file-engi.gz
	gnuplot ./freq-file-cdf.plot

freq-dir-cdf.eps: freq-dir-cdf.plot ../data/freq-dir-corp.gz ../data/freq-dir-engi.gz
	gnuplot ./freq-dir-cdf.plot

freq-inter-file-corp.eps: freq-inter-file-corp.R ../data/freq-inter-file-corp.txt
	./freq-inter-file-corp.R

freq-inter-file-engi.eps: freq-inter-file-engi.R ../data/freq-inter-file-engi.txt
	./freq-inter-file-engi.R

freq-inter-dir-corp.eps: freq-inter-dir-corp.R ../data/freq-inter-dir-corp.txt
	./freq-inter-dir-corp.R

freq-inter-dir-engi.eps: freq-inter-dir-engi.R ../data/freq-inter-dir-engi.txt
	./freq-inter-dir-engi.R


interval-file-pdf.eps: interval-file-pdf.plot ../data/interval-file-engi.txt ../data/interval-file-corp.txt
	./interval-file-pdf.R
#gnuplot interval-file-pdf.plot

interval-file-cdf.eps: interval-file-cdf.plot ../data/interval-file-engi.txt ../data/interval-file-corp.txt
	gnuplot interval-file-cdf.plot

interval-dir-pdf.eps: interval-dir-pdf.plot ../data/interval-dir-engi.txt ../data/interval-dir-corp.txt
	./interval-dir-pdf.R
#	gnuplot interval-dir-pdf.plot

interval-dir-cdf.eps: interval-dir-cdf.plot ../data/interval-dir-engi.txt ../data/interval-dir-corp.txt
	gnuplot interval-dir-cdf.plot


clean:
	rm *.eps ../data/spatial-loc-corp.txt ../data/spatial-loc-engi.txt

