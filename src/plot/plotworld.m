% Plot a world coastline map (file data/maps/world_110m.txt) in figure 112
function plotworld()

fileID = fopen(fullfile(gnss_path('maps'), 'world_110m.txt'), 'rt');

eof = false;
textLine = [];

h = figure(112);
h.Position = [100, 100, 1100, 600];
hold on;
grid;
box on
axis ([-180, 180, -90, 90]);
xlabel('long. (degrees)');
ylabel('Lat. (degrees)');

island = 0;

while true

   while length(textLine) == 0
      textLine = fgetl(fileID);
      if ~ischar(textLine); eof = true; break; end
   end
   
   if eof; break; end

   island = island + 1;
   lineCounter = 1;
   coastline(lineCounter,:) = sscanf(textLine, "%f %f", 2);
   while true
      textLine = fgetl(fileID);
      if length(textLine) ~= 0
         lineCounter = lineCounter + 1;
         coastline(lineCounter,:) = sscanf(textLine, "%f %f", 2);
      else
%          plot(coastline(:,1), coastline(:,2), "Color", [0.9290 0.6940 0.1250]); %works in 2021 version
%          plot(coastline(:,1), coastline(:,2), 'k');
         if island == 113
            fill(coastline(:,1), coastline(:,2), 'w');
         else
            fill(coastline(:,1), coastline(:,2), [0.9290 0.6940 0.1250]); %brown
         end
         clear coastline
         break;
      end
   end
   
end

fclose(fileID);

end
