#' Slices the fracture geometry
#' 
#' Slices the fracture with respect to a specific property, and threshold level
#' 
#' @param obj fracture_geom object
#' @param by name of the property/field by which to slice
#' @param level threshold level on the property
#' @param type type of the returned object (see return value)
#' @param flatten if to snap values to the threshold level
#' @param eps the numerical accuracy to use
#' @param verbose print information about cutting
#' @param edge_is_border if to mark all new edges border edges
#' 
#' @return
#' If type is "all", the function returns the same fracture_geom object, with some of the triangles sliced.
#' If type is "above", the function returns only the part of the geometry, for which property > level
#' "below" returns the opposite.
#' "equal" returns a list(points, edges), where points are points with property == level, and edges are the connecting edges (two columns)
#' 
#' @examples
#' power.iso = function(f) 0.0001 * f^{-4.5}
#' ret = fracture_geom(refine=4, power.iso = power.iso)
#' ret2 = slice(ret, type="above")
#' 
#' @export
slice = function(
    obj,
    by,
    level,
    type=c("all","above","below","equal"),
    flatten=c("edge","above","below","none"),
    edge_is_border,
    cut.triangles=TRUE, cut.edges=TRUE, cut.vertexes=TRUE,
    eps=1e-10,
    verbose=FALSE
  ) {
  type = match.arg(type)
  flatten = match.arg(flatten)
  if (missing(by)) stop("'by' is missing")
  if (! is.character(by)) stop("'by' is not string")
  if (length(by) != 1) stop("'by' is not length one")
  if (! by %in% names(obj$points)) stop("'by' is not one of the fields")
  if (missing(level)) stop("'level' is missing")
  if (! is.numeric(level)) stop("'level' is not numeric")
  if (length(level) != 1) stop("'level' is not length one")
  
  if (is.null(obj$edge)) {
    obj$edge = matrix(nrow=0, ncol=2)
    obj$border = logical(0)
  }
  if (is.null(obj$vertex)) {
    obj$vertex = matrix(nrow=0, ncol=1)
  }
  
  # select points below level
  psel = obj$points[,by] < level
  
  #select triangles crossing level
  i = cbind(psel[obj$triangles[,1]],psel[obj$triangles[,2]],psel[obj$triangles[,3]])
  j = rowSums(i)
  tsel = j > 0 & j < 3
  tr = obj$triangles[tsel,,drop=FALSE]
  #sort vertices in triangles so that first is on the other side then other two
  i = i[tsel,,drop=FALSE]
  j = j[tsel] == 1
  tr = rbind(tr[i[,1] == j,c(1,2,3,drop=FALSE)],tr[i[,2] == j,c(2,3,1),drop=FALSE],tr[i[,3] == j,c(3,1,2),drop=FALSE])
  
  #select edges crossing level
  i = cbind(psel[obj$edge[,1]],psel[obj$edge[,2]])
  j = rowSums(i)
  esel = j > 0 & j < 2
  ed = obj$edge[esel,,drop=FALSE]
  ed_b = obj$border[esel]
  #sort vertices in triangles so that first is on the other side then other two
  i = i[esel,,drop=FALSE]
  j = j[esel] == 1
  ed = rbind(ed[i[,1] == j,c(1,2),drop=FALSE],ed[i[,2] == j,c(2,1),drop=FALSE])

  #generate unique indexes
  i = cbind(
    c(tr[,1],tr[,1],ed[,1]),
    c(tr[,2],tr[,3],ed[,2])
  )
  i[i[,1] > i[,2], ] = i[i[,1] > i[,2], 2:1]
  id = paste(i[,1],i[,2],sep="_")

  a = obj$points[i[,1],by] - level
  b = obj$points[i[,2],by] - level
  t = a/(a-b)
  t[a-b == 0] = 0.5
  t[t<eps] = 0
  t[t>1-eps] = 1
  
  np = obj$points[i[,1],] + (obj$points[i[,2],] - obj$points[i[,1],])*t
  id[t == 0] = NA
  id[t == 1] = NA
  id = as.integer(factor(id)) + nrow(obj$points)
  id[t == 0] = i[t == 0,1]
  id[t == 1] = i[t == 1,2]
  
  id_degen = (id <= nrow(obj$points))
  
  npsel = ! (duplicated(id) | id_degen) 
  np = np[npsel,]
  np_id = id[npsel]
  np = np[order(np_id),]
  np_id = np_id[order(np_id)]
  
  p_on_edge = unique(id)
  obj$points = rbind(obj$points,np)
  
  on_edge = rep(FALSE,nrow(obj$points))
  on_edge[p_on_edge] = TRUE
  above = obj$points[,by] >= level & !on_edge
  below = obj$points[,by] <= level & !on_edge
  
  if (max(abs(obj$points[p_on_edge,by] - level)) > eps) stop("error in slice above ", eps)
  
  if (flatten == "edge") {
    flat = on_edge
  } else if (flatten == "above") {
    flat = on_edge | above
  } else if (flatten == "below") {
    flat = on_edge | below
  } else if (flatten == "none") {
    flat = rep(FALSE,nrow(obj$points))
  } else stop("Unknown flatten parameter")
  obj$points[flat,by] = level
  if (by == "h") {
    obj$points[flat,"f1"] = obj$points[flat,"fm"] + level/2
    obj$points[flat,"f2"] = obj$points[flat,"fm"] - level/2
  } else if (by == "f1") {
    obj$points[flat,"h"]  =  level - obj$points[flat,"f2"]
    obj$points[flat,"fm"] = (level + obj$points[flat,"f2"])/2
  } else if (by == "f2") {
    obj$points[flat,"h"]  =  obj$points[flat,"f1"] - level
    obj$points[flat,"fm"] = (obj$points[flat,"f1"] + level)/2
  }
  tr_id = matrix(id[seq_len(nrow(tr)*2)],ncol=2,nrow=nrow(tr))
  tr_id_degen = matrix(id_degen[seq_len(nrow(tr)*2)],ncol=2,nrow=nrow(tr))
  ed_id = matrix(id[seq_len(nrow(ed)) + nrow(tr)*2],ncol=1,nrow=nrow(ed))
  ed_id_degen = matrix(id_degen[seq_len(nrow(ed)) + nrow(tr)*2],ncol=1,nrow=nrow(ed))
  
  if (missing(edge_is_border)) {
    if (type %in% c("above","below")) {
      if (by == "h" && level == 0) {
        edge_is_border = FALSE
      } else {
        edge_is_border = TRUE
      }
    } else {
      edge_is_border = FALSE
    }
  } else {
    if (! is.logical(edge_is_border)) stop("'edge_is_border' is not logical")
    if (length(edge_is_border) != 1) stop("'edge_is_border' is not of length 1")
  }  
  ntr = NULL
  edge = NULL
  edge_b = NULL
  sel = !tr_id_degen[,1] & !tr_id_degen[,2]
  if (verbose) cat(sum(sel),"triangles trimmed\n")
  ntr = rbind(ntr,
    cbind(tr[sel,1],tr_id[sel,1],tr_id[sel,2]),
    cbind(tr[sel,2],tr_id[sel,2],tr_id[sel,1]),
    cbind(tr[sel,2],tr[sel,3],tr_id[sel,2]))
  sel = tr_id_degen[,1] & !tr_id_degen[,2]
  if (verbose) cat(sum(sel),"triangles cut through 1st vertex\n")
  ntr = rbind(ntr,
              cbind(tr[sel,1],tr[sel,2],tr_id[sel,2]),
              cbind(tr[sel,2],tr[sel,3],tr_id[sel,2]))
  sel = !tr_id_degen[,1] & tr_id_degen[,2]
  if (verbose) cat(sum(sel),"triangles cut through 2nd vertex\n")
  ntr = rbind(ntr,
              cbind(tr[sel,1],tr_id[sel,1],tr[sel,3]),
              cbind(tr[sel,2],tr[sel,3],tr_id[sel,1]))
  sel = tr_id_degen[,1] & tr_id_degen[,2]
  if (verbose) cat(sum(sel),"triangles cut on edge\n")
  ntr = rbind(ntr,
              cbind(tr[sel,1],tr[sel,2],tr[sel,3]))

  sel = (tr_id[,1] != tr_id[,2])
  edge = rbind(edge, cbind(tr_id[sel,1],tr_id[sel,2]))
  edge_b = c(edge_b, rep(edge_is_border,sum(sel)))

  sel = !ed_id_degen[,1]
  edge = rbind(edge,
    cbind(ed[sel,1],ed_id[sel,1]),
    cbind(ed[sel,2],ed_id[sel,1]))
  edge_b = c(edge_b, ed_b[sel])
  sel = ed_id_degen[,1]
  edge = rbind(edge,
               cbind(ed[sel,1],ed[sel,2]))
  edge_b = c(edge_b, ed_b[sel])
  
  vertex = ed_id[,1,drop=FALSE]
  
  obj$triangles = rbind(obj$triangles[!tsel,], ntr)
  obj$edge = rbind(obj$edge[!esel,], edge)
  obj$border = c(obj$border[!esel], edge_b)
  obj$vertex = rbind(obj$vertex, vertex)

  if (type == "equal") {
    psel = on_edge
  } else if (type == "above") {
    psel = on_edge | above
  } else if (type == "below") {
    psel = on_edge | below
  } else if (type == "all") {
    psel = rep(TRUE,nrow(obj$points))
  } else if (type == "none") {
    psel = rep(FALSE,nrow(obj$points))
  } else stop("Unknown flatten parameter")
  
  if (cut.triangles) {
    tsel = psel[obj$triangles]
    dim(tsel) = dim(obj$triangles)
    tsel = rowSums(tsel) == 3
    obj$triangles = obj$triangles[tsel,]
  }
  if (cut.edges) {
    esel = psel[obj$edge]
    dim(esel) = dim(obj$edge)
    esel = rowSums(esel) == 2
    obj$edge = obj$edge[esel,]
    obj$border = obj$border[esel]
  }
  if (cut.vertexes) {
    vsel = psel[obj$vertex]
    dim(vsel) = dim(obj$vertex)
    obj$vertex = obj$vertex[vsel,,drop=FALSE]
  }
  
  psel = rep(FALSE,nrow(obj$points))
  psel[obj$triangles[,1]] = TRUE
  psel[obj$triangles[,2]] = TRUE
  psel[obj$triangles[,3]] = TRUE
  psel[obj$edge[,1]] = TRUE
  psel[obj$edge[,2]] = TRUE
  psel[obj$vertex[,1]] = TRUE
  
  ni = rep(0,nrow(obj$points))
  ni[psel] = seq_len(sum(psel))
  obj$triangles[] = ni[obj$triangles]
  obj$edge[] = ni[obj$edge]
  obj$vertex[] = ni[obj$vertex]
  if (any(rowSums(obj$triangles == 0) != 0)) stop("what?")
  obj$points = obj$points[psel,]

  return(obj)
}

#' Cut the fracture geometry to a box
#' 
#' @param x fracture_geom object
#' @param ... other arguments for slice
#' @export
cut.fracture_geom = function(x, ...){
  x = slice(x, by="x", level=0, type="above", ...)
  x = slice(x, by="x", level=x$width, type="below", ...)
  x = slice(x, by="y", level=0, type="above", ...)
  x = slice(x, by="y", level=x$width, type="below", ...)
  x
}
