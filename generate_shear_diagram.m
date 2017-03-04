%% for non distributed loads
function fig_handle = generate_shear_diagram(load_locations, fig_title_prefix, x_text, y_text)
    %% generate coordinates
    sorted_row_locations = sortrows(load_locations, 1);
    distances = sorted_row_locations(:, 1);
    loads = sorted_row_locations(:, 2);
    
    addl_coords = [];
    
    for i = 1:length(distances)
        if i ~= length(distances)
            addl_coords = [addl_coords; distances(i + 1), loads(i)];
        end
    end
    
    all_coords = [addl_coords; load_locations];
    sorted_coords = sortrows(all_coords, 1);
    x_coords = sorted_coords(:, 1);
    y_coords = sorted_coords(:, 2);
    
    %% plot shear diagram & labels
    handle = figure('Name',strcat(fig_title_prefix, ' Shear Diagram'),'NumberTitle','off');
    plot(x_coords, y_coords);
    xlabel(x_text);
    ylabel(y_text);
    
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position', [1.05 * max(distances) 0 0]);
    
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    axis([-inf, inf, min(y_coords) * 1.1, max(y_coords) * 1.1]);
    
    max_load = 1.1 * max(loads);
    min_load = 1.1 * min(loads);
    max_dist = max(distances);
    min_dist = min(distances);
    
    % stupid placement algorithm for labels that don't work
    for i = 1:length(distances) - 1
        lbl_x = [i / length(distances), ((distances(i) + distances(i + 1)) / 2) / (max_dist - min_dist)];
        lbl_y = [0.5, (loads(i) - min_load) / (max_load - min_load)];
        annotation('textarrow', lbl_x, lbl_y, 'String', sprintf('%0.2f N', loads(i)));
    end
    
    %% assign outputs
    fig_handle = handle;
end