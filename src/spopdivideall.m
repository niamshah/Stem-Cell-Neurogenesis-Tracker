%injection rate: 1uL /second
%(injection vol: 50-200uL)
%Stops at 50,000 events 


    %for the naive coculture 2: 2, 0, 10, 9, [0,3,6,9,12,24,48,72,96,120],
    %80
    nplicate=1; %1 for no repeats, 2 duplicate
    separate=0; %so you don't average the duplicate readings
    reads=7; %number of time points for each flask
    flasks=4; %total number of flasks
    time=[0, 1.5, 4, 4.5, 7.5, 22, 28];
    dfactor=80; % dilution factor *20 (for the flow cytometry PBS dilution) * 2 (for glycerol dilution) 
    minuscontam=0; %to subtract the contamination flask cell counts
    saving=1; %to save the growth curves as .mat files
    
    %TO INITIALIZE:
    load('residuedivs.mat') %(just the first time)
    load('dividers21.mat')  %(just the first time)
    load('contamcoliavgs.mat')
    load('contamhutchavgs.mat')
    
    %diluted=[13]; %add the indices of the readings that had 100uL taken out for dilution
    files = dir('*.fcs'); %the files you're plotting must be .fcs and saved in the current directory
    files=struct2table(files); 
    files=files(:,1);
    files=table2cell(files);
    files=sort_nat(files);
    hutch = zeros(1,reads);
    coli=zeros(1,reads);
    if separate==1
        hutch1=zeros(1,reads);
        coli1=zeros(1,reads);
        hutch2=zeros(1,reads);
        coli2=zeros(1,reads);
    end


for j = 0:9 %specify which flasks you want. flask 1 = 0, flask 2.1=1, 2.2=...
    q=nplicate*j+1;
    for i=0:reads-1
        data=fca_readfcs(files{flasks*nplicate*i+q});
        %disp(files{flasks*nplicate*i+q}); %just for troubleshooting
        if nplicate==2
            data2=fca_readfcs(files{flasks*nplicate*i+q+1});
            [~, ~, ~,hutchsize2,colisize2]=spopdivide(data2,dividers21,residue);
            clear data2;
        end
        [~, ~, ~,hutchsize,colisize]=spopdivide(data,dividers21,residue); %removes events at 0, adjusts for reading time,
        %removes debris, and divides
        clear data;
        %saveas(gcf,files{flasks*nplicate*i+q}(13:20),'epsc'); %for saving the graphs as images

        %title(i); %uncomment this when you set plotting=1 in spopdivide
        hutch(i+1)=hutchsize;
        coli(i+1)=colisize;
        if nplicate==2          
            hutch(i+1)=mean([hutchsize,hutchsize2]);
            coli(i+1)=mean([colisize,colisize2]);
            if separate == 1
                hutch1(i+1)=hutchsize;
                hutch2(i+1)=hutchsize2;
                coli1(i+1)=colisize;
                coli2(i+1)=colisize2;
            end
        end
        
    end

    
    hutch=hutch*dfactor;
    coli=coli*dfactor;
    if minuscontam==1
        hutch=hutch-contamhutchavgs;
        coli=coli-contamcoliavgs;
        
    end

    %vols=[1,1.25,1.1,1.1,1,1,1.25,1,1.1,1,1];
    %hutch=hutch.*vols;
    %coli=coli.*vols;
    % for i =1:size(diluted)
    %     hutch(diluted(i))=hutch(diluted(i))*19/18;
    %     coli(diluted(i))=coli(diluted(i))*19/18;
    % end

   
    if saving==1
        %saving
        txtfile=['File' num2str(j) '.mat'];
        z=[time; coli; hutch].';
        save(txtfile,'time','coli','hutch');
    end
    
    figure
    plot(time,coli,'b',time,hutch,'r');
    
    hold on
    scatter(time,coli);
    scatter(time,hutch);
    hold on
    xlabel('hours');
    ylabel('cells/uL');
    title('hutch=red, coli=blue');
    set(gca, 'yscale','log');
    ylim([10^4,10^7]);
    xlim([0,time(end)]);
    if and(separate ==1,nplicate==2)
        hutch2=dfactor*hutch2;
        coli2=dfactor*coli2;
        hutch1=dfactor*hutch1;
        coli1=dfactor*coli1;
        scatter(time,hutch2,25,[1 0 0],'filled');
        scatter(time,hutch1,25,[1 0 0]);
        scatter(time,coli2,25,[0 0 1],'filled');
        scatter(time,coli1,25,[0 0 1]);
    end
    
end