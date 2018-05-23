%% Shakemaps: Determine Country that gridcell falls into
%Stephanie Lackner, December 21, 2016 (updated: 5/13/18)

%% Input Section
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
CountryPath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/gpw-v4-national-identifier-grid/';
outpath=mappath;

%% Import Data
load([mappath 'ShakeMap_Info.mat']);
load([mappath 'Land_km2.mat']);
load([mappath 'kick_them.mat']);
[country, R] = geotiffread([CountryPath 'gpw-v4-national-identifier-grid.tif']);

%% Clean the map
country=double(country);
country(country<0)=0;

%% Calculate
for event=1:n
    if kick_them(event)==0
        %make empty countrymatrix
        map=eval(['Land_km2.id' num2str(event)]);
        country_map=NaN(nrows(event),ncols(event));
        %go through each gridcell
        for ypos=1:nrows(event)
            for xpos=1:ncols(event)
                %if the cell has a shaking value
                if map(ypos,xpos)>0
                    %get coordinates of gridcell
                    xcoord=ulxmap(event)+(xpos-1)/res_event(event)+1/(2*res_event(event));
                    ycoord=ulymap(event)-(ypos-1)/res_event(event)-1/(2*res_event(event));
                    %Define resolutions
                    res_GPW=120;  % number of cells per degree
                    half=0; %half=1: +1/2 because center of first cell is equal to 180
                    ylim=-60+half/(2*res_GPW);
                    %adjust ccordinates
                    if xcoord<=-180
                        xcoord=xcoord+360;
                    elseif xcoord>180
                        xcoord=xcoord-360;
                    end
                    if xcoord > -180-half/(2*res_GPW)+360
                        xcoord=xcoord-360;
                    end
                    %transform coordinates to respective matrix indeces
                    xpop=ceil((xcoord+180)*res_GPW+half/2);  %ceil((xcoord+(180+1/(2*res_GPW)))*res_GPW);
                    ypop=ceil((85-ycoord)*res_GPW+half/2); %ceil(((85+1/(2*res_GPW))-ycoord)*res_GPW);
                    %get country
                    if ycoord>=ylim
                        country_map(ypos,xpos)=country(ypop,xpop);
                    else
                        country_map(ypos,xpos)=0;
                    end
                    %If their is no country in the cell
                    if country_map(ypos,xpos)==0
                        x1=xcoord-1/(2*res_event(event));
                        x2=xcoord+1/(2*res_event(event));
                        y1=ycoord+1/(2*res_event(event));
                        y2=ycoord-1/(2*res_event(event));

                        %fix coordinates
                        if x1<=-180
                            x1=x1+360;
                        elseif x1>180
                            x1=x1-360;
                        end
                        if x1>-180-half/(2*res_GPW)+360
                            x1=x1-360;
                        end
                        if x2<=-180
                            x2=x2+360;
                        elseif x2>180
                            x2=x2-360;
                        end
                        if x2>-180-half/(2*res_GPW)+360
                            x2=x2-360;
                        end
                        if y1<ylim && y1>ylim-1
                            y1=ylim;
                        end
                        if y2<ylim && y2>ylim-1
                            y2=ylim;
                        end

                        x1land=ceil((x1+180)*res_GPW+half/2);
                        x2land=ceil((x2+180)*res_GPW+half/2);
                        y1land=ceil((85-y1)*res_GPW+half/2);
                        y2land=ceil((85-y2)*res_GPW+half/2);

                        temp=country(y1land:y2land,x1land:x2land);
                        temp(temp==0)=[];
                        if mode(temp)>0
                            country_map(ypos,xpos)=mode(temp);
                        end
                    end
                    %if no country data for that cell exists, pick country that
                    %is most represented in the shakemap
                    if country_map(ypos,xpos)==0
                        x1=ulxmap(event);
                        x2=x1+ncols(event)/res_event(event);
                        y1=ulymap(event);
                        y2=y1-nrows(event)/res_event(event);

                        %fix coordinates
                        if x1<=-180
                            x1=x1+360;
                        elseif x1>180
                            x1=x1-360;
                        end
                        if x1>-180-half/(2*res_GPW)+360
                            x1=x1-360;
                        end
                        if x2<=-180
                            x2=x2+360;
                        elseif x2>180
                            x2=x2-360;
                        end
                        if x2>-180-half/(2*res_GPW)+360
                            x2=x2-360;
                        end
                        if y1<ylim && y1>ylim-1
                            y1=ylim;
                        end
                        if y2<ylim && y2>ylim-1
                            y2=ylim;
                        end

                        x1land=ceil((x1+180)*res_GPW+half/2);
                        x2land=ceil((x2+180)*res_GPW+half/2);
                        y1land=ceil((85-y1)*res_GPW+half/2);
                        y2land=ceil((85-y2)*res_GPW+half/2);

                        temp=country(y1land:y2land,x1land:x2land);
                        temp(temp==0)=[];
                        if mode(temp)>0
                            country_map(ypos,xpos)=mode(temp);
                        end
                    end
                end
            end
        end
        eval(['countrycell.id' num2str(event) '=single(country_map);']);
    end
end


%% Save
save([outpath 'CellCountry.mat'],'countrycell','-v7.3');
display('Done with Step4a!!!')
