library(MASS)
library(flashier)
#set up parameters
dim=50 # TODO change to 300
truncatenum = 40000 # TODO CHANGE to 400000
kMAX = 10 # TODO CHANGE to 100
prior_name = c("point_laplace","point_normal","point_exponential_normal")
prior = list(
    ebnm::ebnm_point_laplace,
    ebnm::ebnm_point_normal,
    list(ebnm::ebnm_point_exponential,ebnm::ebnm_point_normal)
)
backfitting = FALSE
#load in data
path = paste("./data/glove.nosync/glove.6B.",dim,"d.txt",sep="")
words = read.table(path,row.names=1,quote="",comment.char = "",col.names=c("word",1:dim),header=FALSE)
#truncate to a subset of the words.
words = words[1:truncatenum,]
W = as.matrix(words)
#compute and save SVD
svd_decom = svd(W)
write.matrix(svd_decom$d,file=paste("./output/",truncatenum,"_by_",dim,"_singular_values.csv",sep=""))
write.matrix(svd_decom$u,file=paste("./output/",truncatenum,"_by_",dim,"_left_singular_vecs.csv",sep=""))
write.matrix(svd_decom$v,file=paste("./output/",truncatenum,"_by_",dim,"_right_singular_vecs.csv",sep=""))
write.matrix(row.names(words),file=paste("./output/",truncatenum,"_by_",dim,"_words.csv",sep=""))
## Use Flashier to compute factorizations
for (priornum in seq_along(prior)){
    fl = flash(W,greedy.Kmax=kMAX,ebnm.fn=prior[[priornum]],backfit=backfitting)
    L = ldf(fl)$L
    #save output
    filename = paste(truncatenum,"by",dim,prior_name[priornum],"backfit",backfitting,sep="_")
    write.matrix(L,file=paste("./output/",filename,"_L.csv",sep=""))
    save(fl,file=paste("./output/",filename,"_data.RData",sep=""))
}
