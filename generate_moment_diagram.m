%% for non distributed loads
function fig_handle = generate_moment_diagram(load_locations, fig_title_prefix, x_text, y_text)
    %% setup
    distances = load_locations(:, 1);
    loads = load_locations(:, 2);

    %% plot moment diagram & labels
    h = figure('Name',strcat(fig_title_prefix, ' Moment Diagram'),'NumberTitle','off');
    plot(distances, loads);
    xlabel(x_text);
    ylabel(y_text);
    
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position', [1.05 * max(distances) 0 0]);
    
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    axis([-inf, inf, min(loads) * 1.1, max(loads) * 1.1]);
    
    max_load = 1.1 * max(loads);
    min_load = 1.1 * min(loads);
    max_dist = max(distances);
    min_dist = min(distances);
    
    % stupid placement algorithm for labels that don't work
    for i = 2:length(distances) - 1
        lbl_x = [i / length(distances), (distances(i) / (max_dist - min_dist))];
        lbl_y = [0.5, (loads(i) - min_load) / (max_load - min_load)];
        annotation('textarrow', lbl_x, lbl_y, 'String', sprintf('%0.2f N-m', loads(i)));
    end
    
    %% outputs
    fig_handle = h;
end