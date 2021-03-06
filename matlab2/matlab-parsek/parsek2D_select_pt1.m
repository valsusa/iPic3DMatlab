%  parsek2D       -  Assemble hdf5 data for Parsek2D 
%			  
%   parsek2D reads data saved in hdf5 from all processors and assemble them in the 
%   correct topology. The user needs to specify the following variables:
%   results_dir = path where the *.hdf file are saved;
%   variable list = string variable with quantities that will be read. Possible tags are:
%   B, E -> magnetic and electric field
%   A, phi -> potentials
%   J, rho -> current and number densities
%   pressure
%   x, v, ID -> position , velocity, ID
%   k_energy -> kinetic energy
%   E_energy, B_energy -> electric and magnetic energy
%
%   Author: Enrico Camporeale
%   Modified: G. Lapenta for new version of MATLAB
%   email:  e.camporeale@qmul.ac.uk
%   date:   01/01/07

%clear all
%close all

global Lx Ly Lz Nx Ny Nz Dx Dy Dz Dt Th Ncycles Ns c Smooth
global PfaceXright PfaceXleft PfaceYright PfaceYleft PfaceZright PfaceZleft
global PHIfaceXright PHIfaceXleft PHIfaceYright PHIfaceYleft PHIfaceZright PHIfaceZleft 
global EMfaceXright EMfaceXleft EMfaceYright EMfaceYleft EMfaceZright EMfaceZleft

global Np Npcelx Npcely Npcelz NpMax qom
global uth vth wth u_drift v_drift w_drift
global XLEN YLEN ZLEN Nprocs periodicX periodicY periodicZ
global Bx0 By0 Bz0
global code_version


%results_dir='/data/home/u0052182/dist006/parsek/results/' ; % directory for results

%variable_list='B E A phi J rho pressure x v ID';  % list of variable you want to load :
                                                  %  B, E -> magnetic and electric field
                                                  %  A, phi -> potentials
                                                  %  J, rho -> current and number densities
                                                  %  pressure
                                                  %  x, v, ID, q -> position , velocity, ID, q
                                                  %  k_energy -> kinetic energy
                                                  %  E_energy, B_energy -> electric and magnetic energy
                                                 



setting_name=[results_dir 'settings.hdf']; % file with collective settings
processor_name=[results_dir 'proc']; % file with data for each processor (i.e. proc0, proc1, ...)


read_parsek_settings2D (setting_name);

nxc = Nx/XLEN + 2;
nyc = Ny/YLEN + 2;
nxn = nxc + 1;
nyn = nyc + 1;


for i=1:Nprocs
 cart=hdf5read([processor_name,num2str(i-1),'.hdf'],'/topology/cartesian_coord');
 MAP(cart(1)+1,cart(2)+1)=hdf5read([processor_name,num2str(i-1),'.hdf'],'/topology/cartesian_rank')+1;
end

for PROC=1:Nprocs
disp(['Reading data from proc #' num2str(PROC)])
info=hdf5info([processor_name,num2str(PROC-1),'.hdf']);
nGroups=size(info.GroupHierarchy.Groups,2);
    
for i=1:nGroups

if strcmp(info.GroupHierarchy.Groups(i).Name,'/energy')  
    nnGroups=size(info.GroupHierarchy.Groups(i).Groups,2);

    for ii=1:nnGroups

      if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/energy/electric') & strfind (variable_list, 'e_energy')
        E_nrg_time=uint64([]);
        ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            E_nrg_slab(counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            E_nrg_time=[E_nrg_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/energy/electric/cycle_',''))];
        end
        [E_nrg_time,E_nrg_index]=intersect(E_nrg_time,sort(E_nrg_time),'rows');
      end
      
     if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/energy/magnetic') & strfind (variable_list, 'b_energy')
        B_nrg_time=uint64([]);
        ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            B_nrg_slab(counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            B_nrg_time=[B_nrg_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/energy/magnetic/cycle_',''))];
        end
        [B_nrg_time,B_nrg_index]=intersect(B_nrg_time,sort(B_nrg_time),'rows');
     end

              
      if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/energy/kinetic') & strfind (variable_list, 'k_energy')
        nnnGroups=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups,2);
     
          for iii=1:nnnGroups
            for nspec=1:Ns
                if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/energy/kinetic/species_',num2str(nspec-1)])
                 k_nrg_time=uint64([]);
                 ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    for time=time_counter_list
                     eval(['k_nrg_slab' num2str(nspec-1) '(time,PROC)= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);         
                     k_nrg_time=[k_nrg_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/energy/kinetic/species_',num2str(nspec-1),'/cycle_'], ''))];
                    end
                    [k_nrg_time,k_nrg_index]=intersect(k_nrg_time,sort(k_nrg_time),'rows');
                end
            end
          end

      end
    end
   
    
end
   
turntosingle

 
if strcmp(info.GroupHierarchy.Groups(i).Name,'/fields') 
    nnGroups=size(info.GroupHierarchy.Groups(i).Groups,2);
    
    for ii=1:nnGroups

       if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/Bx') & strfind (variable_list, 'B')
            Bx_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Bx_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Bx_time=[Bx_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/Bx/cycle_',''))];
           end
           [Bx_time,Bx_index]=intersect(Bx_time,sort(Bx_time),'rows');
       end

       if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/By') & strfind (variable_list, 'B')
            By_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            By_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            By_time=[By_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/By/cycle_',''))];
           end
           [By_time,By_index]=intersect(By_time,sort(By_time),'rows');
       end

       if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/Bz') & strfind (variable_list, 'B')
            Bz_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Bz_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Bz_time=[Bz_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/Bz/cycle_',''))];
           end
           [Bz_time,Bz_index]=intersect(Bz_time,sort(Bz_time),'rows');
       end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/Ex') & strfind (variable_list, 'E')
            Ex_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Ex_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Ex_time=[Ex_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/Ex/cycle_',''))];
           end
           [Ex_time,Ex_index]=intersect(Ex_time,sort(Ex_time),'rows');
       end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/Ey') & strfind (variable_list, 'E')
            Ey_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Ey_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Ey_time=[Ey_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/Ey/cycle_',''))];
           end
           [Ey_time,Ey_index]=intersect(Ey_time,sort(Ey_time),'rows');
       end
   
        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/fields/Ez') & strfind (variable_list, 'E')
            Ez_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Ez_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Ez_time=[Ez_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/fields/Ez/cycle_',''))];
           end
           [Ez_time,Ez_index]=intersect(Ez_time,sort(Ez_time),'rows');
       end

    end
end

if strcmp(info.GroupHierarchy.Groups(i).Name,'/potentials')
    nnGroups=size(info.GroupHierarchy.Groups(i).Groups,2);
    
    for ii=1:nnGroups
        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/potentials/Ax') & strfind (variable_list, 'A')
            Ax_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Ax_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Ax_time=[Ax_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/potentials/Ax/cycle_',''))];
           end
           [Ax_time,Ax_index]=intersect(Ax_time,sort(Ax_time),'rows');
        end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/potentials/Ay') & strfind (variable_list, 'A')
            Ay_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Ay_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Ay_time=[Ay_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/potentials/Ay/cycle_',''))];
           end
           [Ay_time,Ay_index]=intersect(Ay_time,sort(Ay_time),'rows');
        end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/potentials/Az') & strfind (variable_list, 'A')
            Az_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            Az_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Az_time=[Az_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/potentials/Az/cycle_',''))];
           end
           [Az_time,Az_index]=intersect(Az_time,sort(Az_time),'rows');
        end


        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/potentials/phi') & strfind (variable_list, 'phi')
            phi_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
               counter=counter+1;
            phi_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            phi_time=[phi_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,'/potentials/phi/cycle_',''))];
           end
           [phi_time,phi_index]=intersect(phi_time,sort(phi_time),'rows');
        end

    end
end

turntosingle

if strcmp(info.GroupHierarchy.Groups(i).Name,'/moments')
    nnGroups=size(info.GroupHierarchy.Groups(i).Groups,2);
    
    for ii=1:nnGroups

        for nspec=1:Ns
              
            if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,['/moments/species_',num2str(nspec-1)])
                
                 nnnGroups=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups,2);

                 for iii=1:nnnGroups
                 
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/Jx']) & strfind (variable_list, 'J')
                    Jxs_time=uint64([]);
                    ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                        eval(['Jxs_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                        Jxs_time=[Jxs_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/moments/species_',num2str(nspec-1),'/Jx','/cycle_'], ''))];
                    end
                    [Jxs_time,Jxs_index]=intersect(Jxs_time,sort(Jxs_time),'rows');
                  end

                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/Jy']) & strfind (variable_list, 'J')
                      Jys_time=uint64([]);
                      ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                        eval(['Jys_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                      Jys_time=[Jys_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/moments/species_',num2str(nspec-1),'/Jy','/cycle_'], ''))];
                     end
                     [Jys_time,Jys_index]=intersect(Jys_time,sort(Jys_time),'rows');
                  end
                                    
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/Jz']) & strfind (variable_list, 'J')
                    Jzs_time=uint64([]);
                      ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                        eval(['Jzs_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                     Jzs_time=[Jzs_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/moments/species_',num2str(nspec-1),'/Jz','/cycle_'], ''))];
                     end
                     [Jzs_time,Jzs_index]=intersect(Jzs_time,sort(Jzs_time),'rows');
                  end
                  
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/rho']) & strfind (variable_list, 'rho')
                      rhos_time=uint64([]);
                      ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                        eval(['rhos_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                        rhos_time=[rhos_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/moments/species_',num2str(nspec-1),'/rho','/cycle_'], ''))];
                     end
                     [rhos_time,rhos_index]=intersect(rhos_time,sort(rhos_time),'rows');
                  end

                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pXX']) & strfind (variable_list, 'pressure')
                     p_time=uint64([]);
                      ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                         eval(['pxx_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                         p_time=[p_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/moments/species_',num2str(nspec-1),'/pXX','/cycle_'], ''))];
                     end
                     [p_time,p_index]=intersect(p_time,sort(p_time),'rows');
                  end
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pXY']) & strfind (variable_list, 'pressure')
                    ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                         eval(['pxy_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                     end
                  end
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pXZ']) & strfind (variable_list, 'pressure')
                    ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                         eval(['pxz_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                     end
                  end
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pYY']) & strfind (variable_list, 'pressure')
                    ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                         eval(['pyy_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                     end
                  end
                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pYZ']) & strfind (variable_list, 'pressure')
                      ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                          eval(['pyz_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                      end
                  end

                  if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/moments/species_',num2str(nspec-1),'/pZZ']) & strfind (variable_list, 'pressure')
                    ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                    counter=0;
                    for time=time_counter_list
                        counter=counter+1;
                         eval(['pzz_slab' num2str(nspec-1) '(:,:,counter,PROC) = hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                     end
                  end
                  
                 end
            end
        end
        
   turntosingle
             

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/moments/Jx') & strfind (variable_list, 'J')
            Jx_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
            counter=counter+1;
            Jx_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Jx_time=[Jx_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,['/moments/Jx/cycle_'], ''))];
           end
            [Jx_time,Jx_index]=intersect(Jx_time,sort(Jx_time),'rows');
        end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/moments/Jy') & strfind (variable_list, 'J')
            Jy_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
            counter=counter+1;
            Jy_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Jy_time=[Jy_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,['/moments/Jy/cycle_'], ''))];
           end
           [Jy_time,Jy_index]=intersect(Jy_time,sort(Jy_time),'rows');
        end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/moments/Jz') & strfind (variable_list, 'J')
            Jz_time=uint64([]);
            ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
            counter=counter+1;
            Jz_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            Jz_time=[Jz_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,['/moments/Jz/cycle_'], ''))];
           end
           [Jz_time,Jz_index]=intersect(Jz_time,sort(Jz_time),'rows');
        end

        if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,'/moments/rho') & strfind (variable_list, 'rho')
           rho_time=uint64([]);
           ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Datasets,2);
            counter=0;
           for time=time_counter_list
            counter=counter+1;
            rho_slab(:,:,counter,PROC)=hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time));
            rho_time=[rho_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Datasets(time).Name,['/moments/rho/cycle_'], ''))];
           end
           [rho_time,rho_index]=intersect(rho_time,sort(rho_time),'rows');
        end

    end
  end

turntosingle


if strcmp(info.GroupHierarchy.Groups(i).Name,'/particles')
    nnGroups=size(info.GroupHierarchy.Groups(i).Groups,2);

    for ii=1:nnGroups
  %nspec=ii;
        for nspec=1:Ns
          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Name,['/particles/species_',num2str(nspec-1)])
              nnnGroups=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups,2);
              
             for iii=1:nnnGroups
                 
                         
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/x']) & strfind (variable_list, 'x') 
                                x_time=uint64([]);
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                eval(['x_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);
                                x_time=[x_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/x','/cycle_'], ''))];
                                end
                                [x_time,x_index]=intersect(x_time,sort(x_time),'rows');
                          end
                          
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/y']) & strfind (variable_list, 'x')
                                y_time=uint64([]);   
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                    eval(['y_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);                  
                                y_time=[y_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/y','/cycle_'], ''))];
                                end
                                [y_time,y_index]=intersect(y_time,sort(y_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/z']) & strfind (variable_list, 'x')
                                z_time=uint64([]);
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                  counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                    eval(['z_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);                 
                                    z_time=[z_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/z','/cycle_'], ''))];
                                end
                                [z_time,z_index]=intersect(z_time,sort(z_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/u']) & strfind (variable_list, 'v')
                                u_time=uint64([]); 
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                     eval(['u_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);                  
                                u_time=[u_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/u','/cycle_'], ''))];
                                end
                                [u_time,u_index]=intersect(u_time,sort(u_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/v']) & strfind (variable_list, 'v')
                                v_time=uint64([]);
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                     eval(['v_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);         
                                 v_time=[v_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/v','/cycle_'], ''))];
                                end
                                [v_time,v_index]=intersect(v_time,sort(v_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/w']) & strfind (variable_list, 'v')
                                w_time=uint64([]);
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                     eval(['w_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);     
                                 w_time=[w_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/w','/cycle_'], ''))];
                                end
                                [w_time,w_index]=intersect(w_time,sort(w_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/q']) & strfind (variable_list, 'q')
                                q_time=uint64([]);
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                     eval(['q_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);     
                                 q_time=[q_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/q','/cycle_'], ''))];
                                end
                                [q_time,q_index]=intersect(q_time,sort(q_time),'rows');
                          end
                          if strcmp(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Name,['/particles/species_',num2str(nspec-1),'/ID']) & strfind (variable_list, 'ID')
                                ID_time=uint64([]);  
                                ntime=size(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets,2);
                                counter=0;
                                for time=time_counter_list
                                counter=counter+1;
                                      eval(['ID_slab' num2str(nspec-1) '.time' num2str(counter) '.PROC' num2str(PROC) '= hdf5read(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time));']);              
                                ID_time=[ID_time;str2double(regexprep(info.GroupHierarchy.Groups(i).Groups(ii).Groups(iii).Datasets(time).Name,['/particles/species_',num2str(nspec-1),'/ID','/cycle_'], ''))];
                                end
                               [ID_time,ID_index]=intersect(ID_time,sort(ID_time),'rows');
                          end
                          
                     
                      
    turntosingle
              
                  
                                    
                  
              end
          end
        end
        
    end
end
    
end

end

clear info nGroups nnGroups nnnGroups cart
%%%%%%%%%%%%%%%%%%%%% end of reading from .hdf file
