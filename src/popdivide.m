
%to initialize, do data = fca_readfcs(file path);
function [pop1,pop2, resisum, dividers]= popdivide(data)
figure
%removes the data at zero
data(data(:,3)==0,:) = [];
dividers=[];
scatter(data(:,2),data(:,3),1,'filled')
set(gca, 'xscale','log');
    bins=15;
%     Sort cells into bins
    binspace=linspace(min(data(:,3))-1,max(data(:,3))+1,bins);
    [~,binindex] = histc(data(:,3),binspace); 
    if max(binindex)==0
        disp('no cells in parameter range')
        return
    end
    hutchpop=[];
    colipop=[];
    %run BinDivide the first time giving estimated starting peak locations 
    [hutchpopold,colipopold,hutchplocold,coliplocold, dividers, resisum]=BinDivide(binindex,data,1,400,2*10^3, colipop, hutchpop,binspace, dividers, 0);
    %loop through all the remaining bins, feeding BinDivide its previous outputs as
    %inputs
    for i = 2:bins-1
        [hutchpop,colipop,hutchploc,coliploc, dividers, resisum]=BinDivide(binindex, data, i, hutchplocold,coliplocold, colipopold, hutchpopold,binspace,dividers, resisum);
        hutchpopold=hutchpop;
        colipopold=colipop;
        hutchplocold=hutchploc;
        coliplocold=coliploc;
    end
    
    %%%TO DRAW A LINE OF BEST FIT THRU THE DIVIDERS
    %dividers=dividers(dividers(:,1)<1.5*std(dividers(:,1)),:);
    %p=polyfit(log10(dividers(:,1)),dividers(:,2), 1)
    %x=logspace(log10(min(data(:,2))),log10(max(data(:,2))),200);
    %linx=linspace(min(log10(data(:,2))),max(log10(data(:,2))),200);
   % y = polyval(p,linx);
    %hold on
    %plot(x,y)
    %hutchpop=data(data(:,3)<=polyval(p,log10(data(:,2))),:);
    %colipop=data(data(:,3)>polyval(p,log10(data(:,2))),:);
    %scatter(hutchpop(:,2),hutchpop(:,3),1,'filled');
    %scatter(colipop(:,2),colipop(:,3),1,'filled');
pop1=hutchpop;
pop2=colipop;
ylim([0,3*10^5]);

end