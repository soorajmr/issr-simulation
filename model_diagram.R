library(DiagrammeR)
library(DiagrammeRsvg)
library(xml2)

gr <- grViz("
digraph issr_simulation {

  graph [overlap = false, fontsize = 10.0, rankdir=LR, layout=dot,
         label = '\nThis diagram shows the flow of information in the simulation. Each round-edged box represents a random variable with an associated probability distribution. 
         The rectangular boxes show intermediate metrics calculated from the random variables, \nand further downstream calculations lead to the final outcomes of the simulation, represented by the grey boxes',
         labelloc=b, labeljust=l, fontname=Helvetica]
  
  node [shape = box, style=rounded fontname = Helvetica, fontsize=10]
  A [label = 'Slum Area']; 
  B [label = 'Number of\nHouseholds\nin the Slum Land']; 
  C [label = 'Land Shape\nIndex']; 
  D [label = 'FAR']; 
  E [label = 'Additional\nHouseholds\nto Accommodate']; 
  F [label = 'Redeveloped\nHouse\nSize'];
  G [label = 'Construction Cost\n(Redeveloped House)'];
  H [label = 'Construction Cost\n(Premium House)'];
  I [label = 'Transit\nAccommodation\nCost'];
  J [label = 'Cost Inflation\nFactor'];
  K [label = 'Sale Price\nof TDR'];
  L [label = 'Premium Housing\nSale Price'];
  M [label = 'PMAY\nSubsidy']

  node [shape = box, fontname = Helvetica, style=solid, fontsize=10]
  1 [label = 'Total\nBuildable Area']; 
  3 [label = 'Area Required for\nRedeveloped Houses']; 
  4 [label = 'Total Area\n Available for\nPremium Houses']; 
  6 [label = 'Total Cost']; 
  7 [label = 'Total Revenue']; 
  10 [label = 'Penalty for\nShape'];
  11 [label = 'Total Subsidy'];
  12 [label = 'Total TDR\nGenerated']

  node [shape = box, fontname = Helvetica, style = 'filled, bold', fillcolor = grey, fontsize=10]
  8 [label = 'Project\nFeasibility'];
  9 [label = 'Internal\nRate of Return\n(Profitability)'];
  
  # 'edge' statements
  C->10;
  A->1 10->1 D->1; 
  B->3 E->3 F->3;
  3->4 1->4;
  3->8 1->8;
  G->6 H->6 J->6 I->6 3->6 4->6;
  M->11 3->11;
  K->12 3->12;
  12->7 L->7 11->7 4->7;
  6->9 7->9
}
")

export_svg(gr) %>% read_xml() %>% write_xml("svg/issr_sim_flow.svg")

gr
