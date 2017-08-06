		AREA myprog,DATA,READONLY
		EXPORT beg_prog_dat  ;export pointer to the begining of the data 
		EXPORT end_prog_dat  ;export pointer to the end of data

		ALIGN				; make sure the data is aligned

beg_prog_dat							
				DCD 0xFFFFFFFF	;some data
				DCD 0xFFFFFFFF
				DCD 0xFFFFFFFF
end_prog_dat	DCD 0xFFFFFFFF


		END