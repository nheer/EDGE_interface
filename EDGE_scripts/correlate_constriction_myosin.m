%CORRELATE_CONSTRICTION_MYOSIN
%
% xies@mit.edu Jan 2012
%% Generate correlations

wt = 10;
embryoID = 9;

correlations = nanxcorr( ...
    myosins_rate(:,[IDs.which] == embryoID), ...
    areas_rate(:,[IDs.which] == embryoID),wt,1);

[correlations,no_nan_cells] = delete_nan_rows(correlations,2);

%% Plot myosin, area, rates and average correlation

figure,showsublink(@imagesc,{[1 num_frames],[1 sum(num_cells)],areas_sm'},'Cell areas','colorbar;', ...
    @imagesc,{[1 num_frames],[1 sum(num_cells)],myosins_sm'},'Myosin intensity (clipped)','colorbar' ...
    );

figure,showsublink(@imagesc,{[1 num_frames],[1 sum(num_cells)],coronal_displacements'},'Constriciton rate','colorbar;', ...
    @imagesc,{[1 num_frames],[1 sum(num_cells)],myosins_rate'},'Myosin rate','colorbar' ...
    );

figure

showsub(@imagesc,{([-wt wt])*input(1).dt,[1 num_cells(1)], correlations([IDs.which]==1,:)}, ...
    'Cross-correlation per cell. Embryo #1','colorbar;caxis([-1 1]);', ...
    @errorbar,{(-wt:wt)*input(1).dt,nanmean(correlations([IDs.which]==1,:)),nanstd(correlations([IDs.which]==1,:))},...
    'Mean cross-correlation, embryo #1','axis on',...
    @imagesc,{([-wt wt])*input(3).dt,[1 num_cells(3)], correlations([IDs.which]==3,:)}, ...
    'Cross-correlation per cell. Embryo #3','colorbar;caxis([-1 1]);', ...
    @errorbar,{(-wt:wt)*input(3).dt,nanmean(correlations([IDs.which]==3,:)),nanstd(correlations([IDs.which]==3,:))},...
    'Mean cross-correlation, embryo #3','axis on',...
    @imagesc,{([-wt wt])*input(4).dt,[1 num_cells(4)], correlations([IDs.which]==4,:)}, ...
    'Cross-correlation per cell. Embryo #3','colorbar;caxis([-1 1]);', ...
    @errorbar,{(-wt:wt)*input(4).dt,nanmean(correlations([IDs.which]==4,:)),nanstd(correlations([IDs.which]==4,:))},...
    'Mean cross-correlation, embryo #4','axis on' ...
    );

%% Plot individual correlations
zslice = 1;

cellID = 31;
area_sm = smooth2a(squeeze(areas(:,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,cellID)),1,0);
area_rate = -central_diff_multi(area_sm,1,1);
myosin_rate = central_diff_multi(myosin_sm,1,1);

h = figure(1);showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,area_rate,'r-'}, ...
    ['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_rate,'r-'}, ...
    ['Myosin change in cell #' num2str(cellID)],'' ...
    );
% saveas(h,[handle.io.save_dir '/measurements/cells/cell_' num2str(cellID)])

correlation = nanxcorr(area_rate,myosin_rate,wt,1);
figure,plot(-wt:wt,correlation);
title('Cross correlation between constriction rate and myosin')

%%

win = 20;

foci_corona_corr = zeros(num_frames-win-1,num_cells,2*wt+1);

for i = 1:num_frames-win
    foci_corona_corr(i,:,:) = ...
        nanxcorr(areas_rate(i:i+win,:),myosins_rate(i:i+win,:),wt);
end

figure
dynamic_correlation_ma = nanmax(foci_corona_corr(:,:,wt:wt+2),[],3);
pcolor(dynamic_correlation'),colorbar
axis equal tight, caxis([-1 1]);
title(['Pearson''s correlation between myosin rate and coronal area rate (window ' num2str(win) ')' ])
xlabel('Starting frame)')
ylabel('Cells')

