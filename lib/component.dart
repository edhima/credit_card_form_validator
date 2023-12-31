part of credit_card_form_validator;

class CreditCardForm extends StatefulWidget {
  /// A form state key for this credit card form.
  final GlobalKey<FormState> formKey;


  /// A FormFieldState key for card number text field.
  final GlobalKey<FormFieldState<String>>? cardNumberLabel;

  /// A FormFieldState key for card holder text field.
  final GlobalKey<FormFieldState<String>>? cardHolderLabel;

  /// A FormFieldState key for expiry date text field.
  final GlobalKey<FormFieldState<String>>? expiredDateLabel;

  /// A FormFieldState key for cvv code text field.
  final GlobalKey<FormFieldState<String>>? cvcLabel;


  /// Used to configure the auto validation of [FormField] and [Form] widgets.
  final AutovalidateMode? autovalidateMode;

  /// A validator for card number text field.
  final String? Function(String?)? cardNumberValidator;

  /// A validator for expiry date text field.
  final String? Function(String?)? expiryDateValidator;

  /// A validator for cvv code text field.
  final String? Function(String?)? cvvValidator;

  /// A validator for card holder text field.
  final String? Function(String?)? cardHolderValidator;

  /// Error message string when invalid cvv is entered.
  final String cvvValidationMessage;

  /// Error message string when invalid expiry date is entered.
  final String dateValidationMessage;

  /// Error message string when invalid credit card number is entered.
  final String numberValidationMessage;


  final bool? hideCardHolder;
  final Widget? cvcIcon;
  final int? cardNumberLength;
  final int? cvcLength;
  final double? fontSize;
  final CreditCardTheme? theme;
  final Function(CreditCardResult) onChanged;
  final CreditCardController controller;
  const CreditCardForm({
    Key? key,
    this.theme,
    required this.onChanged,
    required this.formKey,
    this.cardNumberLabel,
    this.cardHolderLabel,
    this.hideCardHolder = false,
    this.expiredDateLabel,
    this.cvcLabel,
    this.cvcIcon,
    this.cardNumberLength = 16,
    this.cvcLength = 4,
    this.fontSize = 16,
    required this.controller,
    this.autovalidateMode,
    this.cvvValidationMessage = 'Please input a valid CVV',
    this.dateValidationMessage = 'Please input a valid date',
    this.numberValidationMessage = 'Please input a valid number',
    this.cardHolderValidator,
    this.cardNumberValidator,
    this.cvvValidator,
    this.expiryDateValidator
  }): super(key: key);

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  Map<String, dynamic> params = {
    "card": '',
    "expired_date": '',
    "card_holder_name": '',
    "cvc": '',
  };

  Map cardImg = {
    "img": 'credit_card.png',
    "width": 30.0,
  };

  Map<String, TextEditingController> controllers = {
    "card": TextEditingController(),
    "expired_date": TextEditingController(),
    "card_holder_name": TextEditingController(),
    "cvc": TextEditingController(),
  };

  String error = '';

  CardType? cardType;

  @override
  void dispose() {
    controllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  void initState() {
    handleController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CreditCardTheme theme = widget.theme ?? CreditCardLightTheme();
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor, width: 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Form(
        key: widget.formKey,
        child:Column(
          children: [
            TextInputWidget(
              theme: theme,
              fontSize: widget.fontSize!,
              controller: controllers['card'],
              label: 'Card number',
              bottom: 1,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.cardNumberLength),
                CardNumberInputFormatter(),
              ],
              onChanged: (val) {
                Map img = CardUtils.getCardIcon(val);
                CardType type =
                    CardUtils.getCardTypeFrmNumber(val.replaceAll(' ', ''));
                setState(() {
                  cardImg = img;
                  cardType = type;
                  params['card'] = val;
                });
                emitResult();
              },
              maxLength: 16,
              minLength: 16,
              validator: widget.cardNumberValidator ??
                      (String? value) {
                    if (value!.isEmpty || value.length < 16) {
                      return 'Enter valid card number';
                    }
                    return null;
                  },
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'images/${cardImg['img']}',
                  package: 'credit_card_form_validator',
                  width: cardImg['width'] as double?,
                ),
              ),
              formKey: widget.cardNumberLabel,
            ),
            if (widget.hideCardHolder == false)
              TextInputWidget(
                formKey: widget.cardHolderLabel,
                theme: theme,
                fontSize: widget.fontSize!,
                label: 'Card holder name',
                controller: controllers['card_holder_name'],
                bottom: 1,
                maxLength: 100,
                minLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "You must enter a valid Name";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    params['card_holder_name'] = val;
                  });
                  emitResult();
                },
                keyboardType: TextInputType.name,
              ),
            Row(
              children: [
                Expanded(
                  child: TextInputWidget(
                    formKey: widget.expiredDateLabel,
                    theme: theme,
                    fontSize: widget.fontSize!,
                    label: 'MM/YY',
                    right: 1,
                    maxLength: 5,
                    minLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter valid date.";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        params['expired_date'] = val;
                      });
                      emitResult();
                    },
                    controller: controllers['expired_date'],
                    formatters: [
                      CardExpirationFormatter(),
                      LengthLimitingTextInputFormatter(5)
                    ],
                  ),
                ),
                Expanded(
                  child: TextInputWidget(
                    formKey:widget.cvcLabel ,
                    theme: theme,
                    fontSize: widget.fontSize!,
                    label: 'CVC',
                    controller: controllers['cvc'],
                    password: true,
                    maxLength: 4,
                    minLength: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter CVC";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        params['cvc'] = val;
                      });
                      emitResult();
                    },
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.cvcLength)
                    ],
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: widget.cvcIcon ??
                          Image.asset(
                            'images/cvc.png',
                            package: 'credit_card_form_validator',
                            height: 25,
                          ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  emitResult() {
    List res = params['expired_date'].split('/');
    CreditCardResult result = CreditCardResult(
      cardNumber: params['card'].replaceAll(' ', ''),
      cvc: params['cvc'],
      cardHolderName: params['card_holder_name'],
      expirationMonth: res[0] ?? '',
      expirationYear: res.asMap().containsKey(1) ? res[1] : '',
      cardType: cardType,
    );
    widget.onChanged(result);
  }

  handleController() {
    if (widget.controller != null) {
      widget.controller?.addListener(() {
        CreditCardValue? initialValue = widget.controller?.value;
        if (initialValue?.cardNumber != null) {
          TextEditingValue cardNumber =
              FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(text: initialValue!.cardNumber.toString()),
          );

          cardNumber = LengthLimitingTextInputFormatter(19).formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(text: cardNumber.text),
          );

          cardNumber = CardNumberInputFormatter().formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(text: cardNumber.text),
          );

          controllers['card']?.value = cardNumber;
        }
        if (initialValue?.cardHolderName != null) {
          controllers['card_holder_name']?.text =
              initialValue!.cardHolderName.toString();
        }
        if (initialValue?.expiryDate != null) {
          controllers['expired_date']?.value =
              CardExpirationFormatter().formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(text: initialValue!.expiryDate.toString()),
          );
        }
      });
    }
  }
}
