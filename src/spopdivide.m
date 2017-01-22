function[hutches,colis,residuesum,hutchsize,colisize]=spopdivide(data,dividers,residuedivs)
    plotting=0;
    binspace=linspace(-1,262145,15); %taken from the bins from which we got the original dividers from
    data(data(:,3)==0,:) = [];
    
    %for each event in data, binindex gives the bin that cell is in
    [~,binindex] = histc(data(:,3),binspace); 
    if max(binindex)==0
        disp('no cells in parameter range')
        return
    end
    hutches=[];
    colis=[];
    residuesum=0;
    %loop through all the bins saving the events below the divider for that
    %bin in hutches, and events above in colis
    for i = 1:14
        temp=data(binindex==i,:);
        hutches=[hutches;temp(temp(:,2)<dividers(i),:)];
        colis=[colis;temp(temp(:,2)>dividers(i),:)];
        a=size(data(data(binindex==i,2)>residuedivs(i)));
        residuesum = residuesum + a(1);
    end
    %remove the debris event count and calculate events per uL
    %data(end) is time in 1/100ths of a second, flow rate is 0.1uL/second
    %so total volume = flow rate * duration of flow =
    %0.1*data(end)*0.01=  data(end)/1000 uL
    c=size(colis);
    colisize=(c(1)-residuesum)*1000/data(end);
    d=size(hutches);
    hutchsize=d(1)*1000/data(end);
    
    
    if plotting==1 %just for troubleshooting
        figure;
        scatter(data(:,2),data(:,3),1,'filled');
        set(gca, 'xscale','log');
        hold on
        scatter(dividers(:,1),dividers(:,2));
        scatter(residuedivs,binspace(1:14));
        
        %scatter(colis(:,2),colis(:,3),1,'filled');
        %scatter(hutches(:,2),hutches(:,3),1,'filled');
        
    end
    
end