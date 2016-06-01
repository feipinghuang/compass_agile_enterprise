Captcha = {
	container: null,
	numberOfImages: null,
	imageName: null,
	imageValues: null,
	imageFieldName: null,
	audioFieldName: null,
	showingAudio: false,
	showingImages: false,
	form: null,
	originalFormSubmit: null,

	setup: function(divId, options) {
		options = $.extend({
			preventFormSubmission: true,
			numberOfImages: 5
		}, options);

		if (options['numberOfImages'])
			Captcha.numberOfImages = options['numberOfImages'];

		Captcha.container = $('#' + divId);

		if (options['preventFormSubmission']) {
			Captcha.form = Captcha.container.parent('form');
			Captcha.originalFormSubmit = Captcha.form.submit;
			Captcha.form.submit(Captcha.formSubmit);
		}

		Captcha.load(Captcha.showImages);
	},

	formSubmit: function(e) {
		e.preventDefault();

		$('.captcha-error').remove();

		Captcha.validate(function(isValid) {
			if (isValid) {
				Captcha.form.unbind('submit', Captcha.formSubmit);
				Captcha.originalFormSubmit.apply(Captcha.form);
			} else {
				Captcha.form.prepend('<div class="alert alert-danger captcha-error">Invalid Captcha</div>');
			}
		}, function() {
			Captcha.form.prepend('<div class="alert alert-danger captcha-error">Error validating Captcha</div>');
		});

		return false;
	},

	load: function(successCallback) {
		$.ajax({
			url: '/captcha/start/' + Captcha.numberOfImages,
			success: function(result) {
				Captcha.imageName = result['imageName'];
				Captcha.imageFieldName = result['imageFieldName'];
				Captcha.audioFieldName = result['audioFieldName'];
				Captcha.imageValues = result['values'];
				successCallback();
			},
			fail: function() {
				Captcha.container.prepend('<div class="alert-danger">Could not load Captcha/div>');
			}
		});
	},

	refresh: function() {
		Captcha.load(Captcha.showImages);
	},

	showImages: function() {
		Captcha.showingImages = true;
		Captcha.container.empty();

		for (var i = 0; i < Captcha.numberOfImages; i++) {
			var img = $('<img class="captcha-img" data-img-value="' + Captcha.imageValues[i] + '" src="' + Captcha.buildImgUrl(i) + '" />').click(Captcha.onImgSelect);

			Captcha.container.append(img);
		}

		var refresh = $('<a class="captcha-refresh"><img src="/assets/icons/refresh/refresh_16x16.png" /></a>').click(Captcha.onRefresh);
		Captcha.container.append(refresh);

		var audio = $('<a class="captcha-audio"><img src="/assets/icons/audio/audio_16x16.png" /></a>').click(Captcha.showAudio);
		Captcha.container.append(audio);

		Captcha.container.append('<input type="hidden" name="' + Captcha.imageFieldName + '" />');
		Captcha.container.prepend('<div class="captcha-instructions">Captcha: Click or touch the <span class="image-name">' + Captcha.imageName + '</span></div>');
	},

	showAudio: function() {
		Captcha.showingAudio = true;
		Captcha.container.empty();

		var formGroup = $('<div class="form-group"></div>');
		formGroup.append('<input type="text" class="form-control captcha-audio-input" required="true" name="' + Captcha.audioFieldName + '" /></div>');

		var refresh = $('<a class="captcha-refresh"><img src="/assets/icons/refresh/refresh_16x16.png" /></a>').click(Captcha.onRefresh);
		formGroup.append(refresh);

		var audio = $('<a class="captcha-audio"><img src="/assets/icons/audio/audio_16x16.png" /></a>');
		formGroup.append(audio);

		Captcha.container.append(formGroup);
		Captcha.container.prepend('<div class="captcha-instructions">Captcha: Type below the <span class="image-name">Anwser</span> to what you hear.  Numbers or words:</div>');
		Captcha.container.append('<audio autoplay="autoplay" src="/captcha/audio" />');
	},

	onRefresh: function() {
		Captcha.refresh();
	},

	validate: function(successCallback, failureCallback) {
		var data = null;

		if (Captcha.showingAudio) {
			data = Captcha.audioFieldName + '=' + $('input[name=' + Captcha.audioFieldName + ']').val();
		} else {
			data = Captcha.imageFieldName + '=' + $('input[name=' + Captcha.imageFieldName + ']').val();
		}

		$.ajax({
			url: '/captcha/validate',
			method: 'PUT',
			data: data,
			success: function(result) {
				successCallback(result.success);
			},
			fail: function() {
				failureCallback();
			}
		});
	},

	onImgSelect: function() {
		Captcha.container.children('img.captcha-img-selected').removeClass('captcha-img-selected').addClass('captcha-img');
		$(this).removeClass('captcha-img').addClass('captcha-img-selected');
		$('input[name=' + Captcha.imageFieldName + ']').val($(this).data('img-value'));
	},

	buildImgUrl: function(index) {
		return "/captcha/image/" + index + '?' + Math.floor((Math.random() * 1000) + 1);
	}
};