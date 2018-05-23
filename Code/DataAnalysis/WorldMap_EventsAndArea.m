%%Area and Distance
%Stephanie Lackner, (updated 5/14/18)
%runs 10min for 2.5, and 12min for 1.25 resvalue

addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/stata_translation');
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_logcolor/')

file='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/ForWorldMap.csv';
[area, R] = geotiffread('/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/gpw-v4-land-water-area-land/gpw-v4-land-water-area_land.tif');
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/';


%% clean
area=(area>0);
%resvalue=2.5;
%resstring='2point5';
resvalue=1.25;
resstring='1point25';

for which=[1 45 6]
    data=csv2mat_numeric(file);
    if which== 1
        sample=ones(length(data.lon),1);
    elseif which==45
        sample=(data.magnitude>=4.5);
    elseif which==6
        sample=(data.magnitude>=5.5).*(data.magnitude<=6.5);
    end

    A_P_PGALand=[data.area_with09percentpeakpga(sample==1) data.area_with05percentpeakpga(sample==1)];
    ECX=data.lon(sample==1);
    ECY=data.lat(sample==1);
    magnitude=data.magnitude(sample==1);
    smind=data.smind(sample==1);
    year=data.year(sample==1);
    clear data

    %% worldmap
    ratio=120*resvalue;
    areasmall90=NaN(size(area)/ratio);
    areasmall50=NaN(size(area)/ratio);
    areasmall90med=NaN(size(area)/ratio);
    areasmall50med=NaN(size(area)/ratio);
    NE=zeros(size(area)/ratio);
    TNE=zeros(size(area)/ratio);
    AMmag=NaN(size(area)/ratio);
    for x=1:360*(120/ratio)
        s1=(round((180+ECX)*(120/ratio)+0.5)==x);
        if sum(s1>0)
            for y=1:(85+60)*(120/ratio)
                s2=(round((85-ECY)*(120/ratio)+0.5)==y);
                if sum(s2>0)
                    selection=s1.*s2;
                    %%Total number of earthquakes
                    %TNE(y,x)=sum(selection);
                    %selection of events with shakemap
                    selectionsm=selection.*(~isnan(smind));
                    %size of 90% area
                    areasmall90(y,x)=log10(mean(A_P_PGALand(selectionsm==1,1)));
                    %%size of 50% area
                    %areasmall50(y,x)=log10(mean(A_P_PGALand(selectionsm==1,2)));
                    %size of 90% area
                    areasmall90med(y,x)=log10(median(A_P_PGALand(selectionsm==1,1)));
                    %%size of 50% area
                    %areasmall50med(y,x)=log10(median(A_P_PGALand(selectionsm==1,2)));
                    %number of earthquakes
                    NE(y,x)=sum(selectionsm);
                    %%average annual magnitude
                    %annualvalue=zeros(30,1);
                    %for year=1981:2010
                    %    annualvalue(year-1980)=max([0; magnitude((selection.*(YMDHMS(:,1)==year))==1)]);
                    %end
                    %AMmag(y,x)=mean(annualvalue);
                end
            end
        end
    end

    if which~=6
        %% map of number of epicenters
        map1=resizem(NE,ratio);
        map=log10(map1);
        map(map<0)=-0.1;
        map((map<0).*area==1)=-0.05;

        %plot
        figure
        imagesc(map);
        %adjust colormap
        cmap=parula(max(map(:))*20+1);
        colormap([1,1,1;0.8,0.8,0.8;  cmap])
        axis off
        title('Number of earthquakes by epicenter location')
        c=logcolorbar;
        xlabel(c,'(log-colorscale)');
        truesize(gcf,size(map)/75)

        set(gcf,'paperunits','points');
        sizeim=get(gcf,'paperposition');
        sizeim=sizeim(3:4);
        set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);

        if which==1
            print(gcf,[outpath 'worldnum_' resstring], '-dpdf');
        elseif which==45
            print(gcf,[outpath 'worldnumABOVE4point5_' resstring], '-dpdf');
        end
        close(gcf)
    end

    %% maps of average spatial size
    figure
    map1=resizem(areasmall90,ratio);
    map1(map1<-1)=-1;
    map=map1;
    map(isnan(map1))=min(map1(:))-0.1;
    map(isnan(map1).*area==1)=min(map1(:))-0.05;

    imagesc(map);
    cmap=parula((max(map(:))-min(map1(:)))*25+1);
    colormap([1,1,1;0.8,0.8,0.8;  cmap])
    axis off
    if which==6
        title('Average strong motion area (with 90% of maximum PGA) by epicenter location (5.5 \leq M \leq 6.5)')
    else
        title('Average strong motion area (with 90% of maximum PGA) by epicenter location')
    end
    c=logcolorbar;
    xlabel(c,'km^2 (log-colorscale)');
    truesize(gcf,size(map)/75)

    set(gcf,'paperunits','points');
    sizeim=get(gcf,'paperposition');
    sizeim=sizeim(3:4);
    set(gcf, 'PaperSize', [sizeim(1)-75 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);

    if which==1
        print(gcf,[outpath 'meanarea_90percent_' resstring], '-dpdf');
    elseif which==6
        print(gcf,[outpath 'only6_' resstring], '-dpdf');
    elseif which==45
        print(gcf,[outpath 'meanarea_90percent45_' resstring], '-dpdf');
    end
    close(gcf)

end

display('DONE with WorldMap_EventsAndArea!!!')
