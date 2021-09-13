proc ds2 libs=work;
data _null_;

  /* init() - system method */
  method init();
    declare varchar(16) message; /* method (local) scope */
    message = 'Hello World!';
    put message;
  end;
enddata;
run;
quit;
