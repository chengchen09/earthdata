/***********************************************************************
* Filename : text2nc4.c
* Create : Chen Cheng 2011-04-19
* Description: 
* Modified   : 
* Revision of last commit: $Rev$ 
* Author of last commit  : $Author$ $date$
* licence :
$licence$
* **********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netcdf.h>
#include <mpi.h>

#include "xml_parser.h"

#define DIM_NAME_LEN 50

#define NC_ASSERT(status) do { \
	if((status) != NC_NOERR) { \
		fprintf(stderr, "Line %d: %s\n", __LINE__, strerror(status)); \
		exit(1); \
	} \
}while(0)
	 
struct att_xml_t att_list[ATT_MAX_NUM];
struct var_xml_t var_list[VAR_MAX_NUM];
struct dim_xml_t dim_list[DIM_MAX_NUM];
int natts = 0;
int nvars = 0;
int ndims = 0;

void get_var_info(struct var_xml_t *var_p, nc_type *type, int *dim_num, char **dim_names) {
	char *sep = " ";
	char *shape, *token;
	int i = 0;

	
	if((strcmp(var_p->type, "int 2")) == 0)
		*type = NC_SHORT;
	else if((strcmp(var_p->type, "int 4")) == 0)
		*type = NC_INT;
	else if((strcmp(var_p->type, "int 8")) == 0)
		*type = NC_INT64;
	else if((strcmp(var_p->type, "uint 2")) == 0)
		*type = NC_USHORT;
	else if((strcmp(var_p->type, "uint 4")) == 0)
		*type = NC_UINT;
	else if((strcmp(var_p->type, "uint 8")) == 0)
		*type = NC_UINT64;
	else if((strcmp(var_p->type, "float 4")) == 0)
		*type = NC_FLOAT;
	else if((strcmp(var_p->type, "float 8")) == 0)
		*type = NC_DOUBLE;
	else {
		fprintf(stderr, "type defined is not supported in variable %s\n", var_p->name);
		exit(1);
	}

	shape = (char *)malloc((strlen(var_p->shape) + 1) * sizeof(char));
	if(shape == NULL) {
		fprintf(stderr, "LINE %d: memory allocate error\n", __LINE__);
		exit(1);
	}
	strcpy(shape, var_p->shape);
	
	token = strtok(shape, sep);
	while(token){
		strcpy(&(dim_names[i][0]), token);
		i++;
		token = strtok(NULL, sep);
	}

	*dim_num = i;
	free(shape);

}

void write_nc_header(int grp_id) {
	int i, j, status, dim_num;
	int varid;
	int *dimids, *var_dimids;
	size_t len;
	char **dim_names;
	nc_type type;

	for(i = 0; i < natts; i++) {
		len = strlen(att_list[i].value);
		status = nc_put_att_text(grp_id, NC_GLOBAL, att_list[i].name, len + 1, att_list[i].value);
		NC_ASSERT(status);
	}


	dimids = (int *)malloc(ndims * sizeof(int));
	if(dimids == NULL){
		fprintf(stderr, "memory allocate error!\n");
		exit(1);
	}
	for(i = 0; i < ndims; i++) {
		status = nc_def_dim(grp_id, dim_list[i].name, atoi(dim_list[i].length), &(dimids[i]));
		NC_ASSERT(status);
	}


	/* define variable */
	var_dimids = (int *)malloc(ndims * sizeof(int));
	dim_names = (char **)malloc(ndims * sizeof(char *));
	for(i = 0; i < ndims; i++)
		dim_names[i] = (char *)malloc(DIM_NAME_LEN * sizeof(char));

	for(i = 0; i < nvars; i++) {
		get_var_info(&var_list[i], &type, &dim_num, dim_names);
		for(j = 0; j < dim_num; j++) {
			status = nc_inq_dimid(grp_id, dim_names[j], &var_dimids[j]);
			NC_ASSERT(status);
		}
		status = nc_def_var(grp_id, var_list[i].name, type, dim_num, var_dimids, &varid);
		/* varialbe dimension */
		for(j = 0; j < var_list[i].natts; j++) {
			len = strlen(var_list[i].att_list[j].value);
			status = nc_put_att_text(grp_id, varid, var_list[i].att_list[j].name, len + 1, var_list[i].att_list[j].value);
			NC_ASSERT(status);
		}
		NC_ASSERT(status);
	}
	
	for(i = 0; i < ndims; i++)
		free(dim_names[i]);
	free(dim_names);
	free(var_dimids);
	free(dimids);
}

int main(int argc, char **argv) {
	if(argc < 4) {
		fprintf(stderr, "Usage: text2nc4 xml-infile text-infile nc-outfile\n");
		exit(1);
	}

	int ncfile_id, grp_id;
	int status;

	MPI_Comm comm = MPI_COMM_WORLD;
	MPI_Info mpi_info = MPI_INFO_NULL;

	MPI_Init(&argc, &argv);

	parser_xml_file(argv[1]);

	status = nc_create_par(argv[3], NC_NETCDF4 | NC_MPIIO, comm, mpi_info, &ncfile_id); 
	NC_ASSERT(status);
	//NC_ASSERT(nc_def_grp(ncfile_id, "/", &grp_id));
	
	write_nc_header(ncfile_id);

	NC_ASSERT(nc_close(ncfile_id));
	MPI_Finalize();
	return 0;
}

	/*for(i = 0; i < ndims; i++)
	  printf("dimension %s = %s\n", dim_list[i].name, dim_list[i].length);

	for(i = 0; i < natts; i++)
	  printf("attribute %s = %s\n", att_list[i].name, att_list[i].value);

	for(i = 0; i < nvars; i++) {
	  printf("variable %s %s %s\n", var_list[i].name, var_list[i].shape, var_list[i].type);
	  for(j = 0; j < var_list[i].natts; j++)
		  printf("\tattribute %s = %s\n", var_list[i].att_list[j].name, var_list[i].att_list[j].value);
	}*/

