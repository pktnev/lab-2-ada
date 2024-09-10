with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Main is
   number_of_cells : constant Long_Long_Integer := 200000;
   thread_num : constant Long_Long_Integer := 3;
   index_random : Long_Long_Integer := 7832;
   arr : array(0..number_of_cells) of Long_Long_Integer;

   procedure Init_Arr is
   begin
      for i in 0..number_of_cells loop
         arr(i) := i;
      end loop;
      arr(index_random) := arr(index_random) * (-1);
   end Init_Arr;

   function part_min(start_index, finish_index : Long_Long_Integer) return Long_Long_Integer is
      min : Long_Long_Integer := arr(start_index);
   begin
      for i in start_index+1..finish_index loop
         if min > arr(i) then
            min := arr(i);
         end if;
      end loop;
      return min;
   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : Long_Long_Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(min : Long_Long_Integer);
      entry get_min(min2 : out Long_Long_Integer);
   private
      tasks_count : Long_Long_Integer := 0;
      min1 : Long_Long_Integer := arr(0);
   end part_manager;

   protected body part_manager is
      procedure set_part_min(min : Long_Long_Integer) is
      begin
         if min1 > min then
            min1 := min;
         end if;
         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(min2 : out Long_Long_Integer) when tasks_count = thread_num is
      begin
         min2 := min1;
      end get_min;
   end part_manager;

   task body starter_thread is
      min : Long_Long_Integer;
      start_index, finish_index : Long_Long_Integer;
   begin
      accept start(start_index, finish_index : Long_Long_Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;

      min := part_min(start_index, finish_index);
      part_manager.set_part_min(min);
   end starter_thread;

   function parallel_sum return Long_Long_Integer is
      min : Long_Long_Integer;
      thread : array(1..thread_num) of starter_thread;
      len : Long_Long_Integer := number_of_cells / thread_num;
   begin
      for i in 1..thread_num-1 loop
         thread(i).start((i-1)*len, i*len - 1);
      end loop;
      thread(thread_num).start((thread_num-1)*len, number_of_cells);

      part_manager.get_min(min);
      return min;
   end parallel_sum;

   start_time : Time;
   end_time : Time;
   elapsed_time : Duration;
   result : Long_Long_Integer;
begin
   Init_Arr;

   start_time := Clock;
   result := part_min(0, number_of_cells);
   end_time := Clock;
   elapsed_time := end_time - start_time;
   Put_Line("Minimum value in array (single-threaded): " & Long_Long_Integer'Image(result));
   Put_Line("Elapsed time for single-threaded: " & Duration'Image(elapsed_time));

   start_time := Clock;
   result := parallel_sum;
   end_time := Clock;
   elapsed_time := end_time - start_time;
   Put_Line("Minimum value in array (multi-threaded): " & Long_Long_Integer'Image(result));
   Put_Line("Elapsed time for multi-threaded: " & Duration'Image(elapsed_time));
end Main;
