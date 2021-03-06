# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script to auto-generate BigQuery schema and clean the data for BigQuery ingestion
library(testthat)

# Preprocessing performed: none
dataDir <- './'

# Load Data
data <- read.delim(file.path(dataDir, 'variant_summary.txt.gz'),
                   na.strings=c('-'))
expect_that(nrow(data), equals(71356))
expect_that(ncol(data), equals(24))

# Clean column names
colnames(data) <- tolower(colnames(data))
colnames(data) <- gsub('\\.+', '_', colnames(data))
colnames(data) <- gsub('^x_', '', colnames(data))
colnames(data) <- gsub('_$', '', colnames(data))

# Generate BQ Schema
cols <- colnames(data)
schema <- c()
for (i in 1:length(cols)) {
    type <- 'STRING'
    if ('logical' == class(data[, i])) {
        type <- 'BOOLEAN'
    } else if ('numeric' == class(data[, i])) {
        type <- 'FLOAT'
    } else if ('integer' == class(data[, i])) {
        type <- 'INTEGER'
    }
    schema <- append(schema, paste(cols[i], ':', type, sep='', collapse=','))
}
print(paste(schema, collapse=','))

# Spot check our result
expect_that(as.character(subset(data, alleleid == 25872,
                                select=clinicalsignificance)[1, 1]),
            equals('Pathogenic'))
expect_that(subset(data, alleleid == 25872, select=geneid)[1, 1], equals(2245))

# Write out file to load into BigQuery
write.table(data, file.path(dataDir, 'clinvar.csv'), row.names=FALSE,
            sep='\t', na='')

# TODO(deflaux):
# (1) don't lower case column names
# (2) incorporate descriptions in next import from
#     ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/README.txt
