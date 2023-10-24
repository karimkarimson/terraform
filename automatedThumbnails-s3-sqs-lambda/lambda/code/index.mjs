import { HeadObjectCommand, S3Client, GetObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3';

import { Readable } from 'stream';

import sharp from 'sharp';

const THUMBNAIL_BUCKET = "thumbnails-913466129429x";
const WIDTH = 200;

// create S3 client
const s3 = new S3Client({ region: 'eu-central-1' });

export const handler = async (event) => {
    console.log(event.Records[0].body);
    const record = JSON.parse(event.Records[0].body);


    console.log("########## RECORD:");
    console.info(record);

    const s3Obj = record[0].s3;
    console.log("######### OBJECT:");
    console.info(s3Obj);

    const bucketName = s3Obj.bucket.name;

    console.log("BUCKET NAME:   " + bucketName);

    const objectKey = s3Obj.object.key;

    console.log("OBJECT KEY:   " + objectKey);
    console.log("checking for duplicates");
    try {
        const testparams = {
            Bucket: THUMBNAIL_BUCKET,
            Key: objectKey
        };
        // await s3.headObject(testparams).promise();
        const headResult = await s3.send(new HeadObjectCommand(testparams));
        console.log("############# Object Found  #####   HEAD RESULT:");
        console.info(headResult);
        return;
    } catch (error) {
        if (error.name === 'NotFound') {
            console.log('File does not exist in destination bucket, so trigger compression and upload');
        }
        else {
            console.log("###### Object Not Found - Error Response:");
            console.log(error);
        }
    }
    // Get the image from the source bucket. GetObjectCommand returns a stream.
    try {
        const params = {
            Bucket: bucketName,
            Key: objectKey
        };
        var response = await s3.send(new GetObjectCommand(params));
        console.log("############### RESPONSE:");
        console.info(response);
        var stream = response.Body;

        // Convert stream to buffer to pass to sharp resize function.
        if (stream instanceof Readable) {
            var content_buffer = Buffer.concat(await stream.toArray());
        } else {
            throw new Error('Unknown object stream type');
        }
    } catch (error) {
        console.log(error);
        return;
    }

    // Use the sharp module to resize the image and save in a buffer.
    try {
        var output_buffer = await sharp(content_buffer).resize(WIDTH).toBuffer();
        console.log("buffer for upload created");
    } catch (error) {
        console.log(error);
        return;
    }

    // Upload the thumbnail image to the destination bucket
    try {
        const destparams = {
            Bucket: THUMBNAIL_BUCKET,
            Key: objectKey,
            Body: output_buffer,
            ContentType: "image"
        };
        const putResult = await s3.send(new PutObjectCommand(destparams));
    } catch (error) {
        console.log(error);
        return;
    }
    console.log('Successfully resized ', objectKey);
};