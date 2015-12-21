/*
 * Copyright (c) 2014 Wipro Limited
 * All Rights Reserved
 *
 * This code is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

package com.wipro.ats.bdre.datagen.mr;

import com.wipro.ats.bdre.datagen.Table;
import com.wipro.ats.bdre.datagen.util.Config;
import com.wipro.ats.bdre.datagen.util.TableUtil;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.util.List;

/**
 * The Mapper class that given a row number, will generate the appropriate
 * output line.
 */
public class RecordGenMapper
        extends Mapper<LongWritable, NullWritable, Text, Text> {
    private Table table;
    private TableUtil tableUtil;
    private String pid;
    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        tableUtil=new TableUtil();
        pid=context.getConfiguration().get(Config.PID_KEY);
        table = tableUtil.formTableFromConfig(pid);
        super.setup(context);

    }
    @Override
    public void map(LongWritable row, NullWritable ignored,Context context) throws IOException, InterruptedException {
        String StrRow = tableUtil.getDelimitedTextRow(table,pid);
        context.write(new Text(StrRow),new Text(""));
    }

    @Override
    public void cleanup(Context context) {

    }
}