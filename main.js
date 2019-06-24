// SEND iOS PUSH NOTIFICATION
Parse.Cloud.define("pushiOS", function(request, response) {

  var user = request.user;
  var params = request.params;
  var userObjectID = params.userObjectID
  var data = params.data

  var recipientUser = new Parse.User();
  recipientUser.id = userObjectID;

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("userID", userObjectID);

  Parse.Push.send({
    where: pushQuery,
    data: data
  }, { success: function() {
      console.log("#### PUSH SENT!");
  }, error: function(error) {
      console.log("#### PUSH ERROR: " + error.message);
  }, useMasterKey: true});
  response.success('success');
});


// REPORT A USER  ----------------------------------------
Parse.Cloud.define("reportUser", function(request, response) {

    var userId = request.params.userId;
    var reportedBy = request.params.reportedBy;

    // Query
    var User = Parse.Object.extend('_User'),
    user = new User({ objectId: userId });
    user.set('reportedBy', reportedBy);

    Parse.Cloud.useMasterKey();
    user.save(null, { useMasterKey: true } ).then(function(user) {
        response.success(user);
    }, function(error) {
        response.error(error)
    });
});


// BLOCK/UNBLOCK A USER  ----------------------------------------
Parse.Cloud.define("blockUnblockUser", function(request, response) {

    var userId = request.params.userId;
    var blockedBy = request.params.blockedBy;

    // Query
    var User = Parse.Object.extend('_User'),
    user = new User({ objectId: userId });
    user.set('blockedBy', blockedBy);

    Parse.Cloud.useMasterKey();
    user.save(null, { useMasterKey: true } ).then(function(user) {
        response.success(user);
    }, function(error) {
        response.error(error)
    });
});


// SEND ANDROID PUSH NOTIFICATION
Parse.Cloud.define("pushAndroid", function(request, response) {

  var user = request.user;
  var params = request.params;
  var userObjectID = params.userObjectID;
  var data = params.data;

  
  var recipientUser = new Parse.User();
  recipientUser.id = userObjectID;

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("userID", userObjectID);


  Parse.Push.send({
    where: pushQuery, // Set our Installation query
    data: {
       alert: data
    }  
}, { success: function() {
      console.log("#### PUSH OK");
  }, error: function(error) {
      console.log("#### PUSH ERROR" + error.message);
  }, useMasterKey: true});

  response.success('success');
});

//---------------------------------
// MARK - SET DEVICE TOKEN - FOR ANDROID PUSH NOTIFICATIONS
//---------------------------------
Parse.Cloud.define("setDeviceToken", function(request, response) {
    var installationId = request.params.installationId;
    var deviceToken = request.params.deviceToken;

    var query = new Parse.Query(Parse.Installation);
    query.get(installationId, {useMasterKey: true}).then(function(installation) {
        console.log(installation);
        installation.set("deviceToken", deviceToken);
        installation.save(null, {useMasterKey: true}).then(function() {
            response.success(true);
        }, function(error) {
            response.error(error);
        })
    }, function (error) {
        console.log(error);
    })
});
