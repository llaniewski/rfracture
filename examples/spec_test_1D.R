library(rfracture)
library(rgl)
library(progress)
library(parallel)

cores=detectCores()
cl <- makeCluster(cores-1)

nx = seq(0,1,len=300)
refine = 2^(1:5)
freq = NULL
method = "diagonals"
#power.spectrum = exp_spectrum(scale=0.02,alpha=2)
#power.spectrum = function(f) ifelse(f<5, 0, 0.004/(f^2))
power.spectrum = function(f) 0.004/(f^3)
#power.spectrum = function(f) 0.02^2*exp(-2*(f/5)^2)
repetitions = 200

tab = expand.grid(refine=refine, gauss.order = 1, stringsAsFactors = FALSE)
pb <- progress_bar$new(total = nrow(tab))

sp = lapply(seq_len(nrow(tab)), function(i) {
  refine = tab$refine[i]
  gauss.order = tab$gauss.order[i]
  #ret = fracture_geom(width=1, refine=refine, corr.profile=function(lambda) 1,gap=0.05, power.spectrum=power.spectrum, seed=123, method=method)
  clusterExport(cl = cl, varlist = c("refine","method","power.spectrum","nx","gauss.order"),envir = environment())
  ny = parSapplyLB(cl, seq_len(repetitions), function(j) {
    library(rfracture)
    ret = fracture_matrix(5*refine, corr.profile=function(lambda) 1,gap=0.05, power.iso=power.spectrum,gauss.order = gauss.order)
    x = c(as.vector(ret$points),1)
    y = c(as.vector(ret$f1),ret$f1[1])
    y
  })
  
  tny = ts(ny, deltat = 1/(5*refine))
  
  #sp = myspectrum(tny,plot=FALSE)
  sp = spectrum(tny,plot=FALSE)
  sp$spec = rowMeans(sp$spec)
  pb$tick()
  sp
})
stopCluster(cl)

tab$refine_f = factor(tab$refine*5)

freq = range(sapply(sp, function(x) range(abs(x$freq))))
speclim = range({x = sapply(sp, function(x) range(x$spec)); x[x<1e-16] = NA; x}, na.rm = TRUE)
freq = seq(freq[1],freq[2],len=200)

pdf("spec1D.pdf")
plot(freq, power.spectrum(freq), type="n", log="y", ylim=speclim, xlab="Frequency [1/m]", ylab="PSD [m2]", lty=2, yaxt='n')
for (i in 1:length(sp)) {
  points(sp[[i]]$freq, sp[[i]]$spec, col=as.integer(tab$refine_f[i]))
}
lines(freq, power.spectrum(freq), lty=2, lwd=2)
legend("topright", legend=levels(tab$refine_f), lty=1, col=1:nlevels(tab$refine_f), title="Resolution")
a = log10(axTicks(2))
a = floor(min(a)):ceiling(max(a))
axis(2, at=10^a, labels = sapply(a, function(a) as.expression(bquote(10**.(a)))))
dev.off()
