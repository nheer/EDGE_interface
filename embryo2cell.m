function cells = embryo2cell(embryo_stack)
%EDGE2CELL Converts an EMBRYO_STACK( See EDGE2EMBRYO) into a CellObj.
%
% USAGE: cells = edge2cell(embryo_stack);
%
% xies@mit.edu Feb 2013.

num_cells = [embryo_stack.num_cell];
num_cells_padded = cumsum([0 num_cells]);

% [cells(1:sum(num_cells)).embryoID] = deal([]);
measurements = setdiff(fieldnames(embryo_stack), ...
    {'input','dev_time','dev_frame','num_cell','num_frame'});

allowed_names = properties('CellObj');
measurements = intersect( measurements, allowed_names );

for i = 1:sum(num_cells)
    
    % Collect the indices
    embryo_index = find( (num_cells_padded - i) < 0, 1, 'last');
    cellID = i - num_cells_padded(embryo_index);
    
	stackID = embryo_stack(embryo_index).input.embryoID * 1000 ...
		+ cellID;

    this_cell.embryoID = embryo_stack(embryo_index).input.embryoID;
    this_cell.stackID = stackID;
    this_cell.cellID = cellID;
    
    % Get input structure
    %     input = embryo_stack(embryoID).input;
    
    % Put the relevant measurements into the cell structure
    for j = 1:numel(measurements)
        
        if embryo_stack(embryo_index).input.fixed
            meas_this_cell = ...
                embryo_stack( embryo_index ).(measurements{j})(cellID);
        else
            % Extract single measurement for this cell
            meas_this_cell = ...
                embryo_stack( embryo_index ).(measurements{j})(:,cellID);
        end
        
        % Try to make into numeric array
        try cell2mat(meas_this_cell);
        catch err
            % do nothing
        end
        
        this_cell.(measurements{j}) = ...
            meas_this_cell;
    end
    
    % Collect the time
    this_cell.dev_time = embryo_stack( embryo_index ).dev_time;
    this_cell.folder_name = embryo_stack( embryo_index ).input.folder2load;
    
    % Construct CellObj
    cells(i) = CellObj(this_cell);
    % Manually set initial values for Pulses
    cells(i).flag_fitted = 0;
    cells(i).flag_tracked = 0;
    cells(i).num_fits = 0;
    cells(i).num_tracks = 0;
    
end

end
